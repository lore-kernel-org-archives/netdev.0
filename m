From: Wolfgang Rosner <wrosner@tirnet.de>
Subject: teql and vlan not compatible?
Date: Tue, 7 Apr 2015 20:50:37 +0100
Message-ID: <201504072150.40209.wrosner@tirnet.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tirnet.de ([217.7.138.221]:17798 "EHLO mail.tirnet.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753049AbbDGTut (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Apr 2015 15:50:49 -0400
Received: from wjrws2 (p54BECF13.dip0.t-ipconnect.de [84.190.207.19])
	by mail.tirnet.de (mailserver tirnet.de) with ESMTP id 293F72C1BE
	for <netdev@vger.kernel.org>; Tue,  7 Apr 2015 21:52:14 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

are teql and vlan mutually exclusive?

I've done some tests the last days that drove me crazy, until I found an an 
old (2003) message on the linux.drivers.vlan list :

"vlan + teql qdisc problem"

http://osdir.com/ml/linux.drivers.vlan/2003-02/msg00050.html

<quote>
tc qdisc add dev vlan0003 root teql0
then i can no longer ping 10.0.0.2 from 10.0.0.1.
The moment I add qdisc it stop working.
When I remove qdisc - I can ping again.
</quote>


While my setup is more complicated, the problem is the same.
I cannot even see any arp requests on the wireshark after I have a teql'd 
interface on a vlan like this
"tc qdisc replace dev eth9.42 root teql0"

Is this a fundamental impossibility or is there simply some secret magic I 
just haven't found documented?
Above thread is the only google hit for "teql & vlan"

Thanks for any hint!



Wolfgang Rosner
