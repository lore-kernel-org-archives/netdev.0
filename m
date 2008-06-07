From: Michele Petrazzo - Unipex srl <michele.petrazzo@unipex.it>
Subject: vlan lost tag
Date: Sat, 07 Jun 2008 18:29:40 +0200
Message-ID: <484AB774.3020608@unipex.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay0.fra.interoute.net ([212.23.33.89]:42200 "EHLO
	relay0.fra.interoute.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762912AbYFGQzg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jun 2008 12:55:36 -0400
Received: from debian-srv (unknown [89.202.235.9])
	by relay0.fra.interoute.net (Postfix) with ESMTP id 7E223BEE4
	for <netdev@vger.kernel.org>; Sat,  7 Jun 2008 16:29:40 +0000 (UTC)
Received: from [192.168.1.103] (michele [192.168.1.103])
	by debian-srv (Postfix) with ESMTP id 4BAF77082F
	for <netdev@vger.kernel.org>; Sat,  7 Jun 2008 18:29:40 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,
(I hope that this is the right ml, since vlan one seem to be closed).
I have a problem with two linux-box configured with a vlan and a HP
switch (1700 serie):
I configure the switch with the port 2 and 4 (where pcs are connected)
for only allow to pass the tag 16, configure both linux-box with vlan
16, but the communication starts but doesn't end.

My tests:

pc1 -> ping pc2
pc1 -> tcpdump -> vlan 16, p 0, arp who-has pc2 tell pc1

(nothing other, or better, one per second :) )

pc2 -> tcpdump -> arp who-has pc2 tell pc1
pc2 -> tcpdump -> arp reply pc2 is-at XXXX (the mac)

And no other traffic.

Like you can see, on the pc2, there is no "vlan" string into the tcpdump
output...

If I try to start the communication from the pc2, it's the same. The
packet leave with the vlan 16 and arrive without it. Can be a
switch problem?

Another try that I do was to disable the switch vlan control (hp call
it "vlan aware enabled port") for my two ports and now the traffic shown
by tcpdump are both with "vlan 16" and the communication works!!!

What can be?

Thanks,
Michele
