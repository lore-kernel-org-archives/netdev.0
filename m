From: Patrick McHardy <kaber@trash.net>
Subject: Re: hard hang through qdisc
Date: Thu, 31 Jan 2008 15:02:26 +0100
Message-ID: <47A1D4F2.6080904@trash.net>
References: <200801311321.01015.ak@suse.de> <1201782841.4732.11.camel@localhost> <200801311428.48175.ak@suse.de> <47A1CD4E.7050701@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org
To: Andi Kleen <ak@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49530 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764427AbYAaOCj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 09:02:39 -0500
In-Reply-To: <47A1CD4E.7050701@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> Andi Kleen wrote:
>>> ---------
>>> lilsol:~# tc qdisc add dev eth0 root tbf rate 1000 burst 10 limit 100
>>> lilsol:~# uname -a
>>> Linux lilsol 2.6.24 #1 PREEMPT Sun Jan 27 09:22:00 EST 2008 i686
>>
>> Can you try it again with current git mainline?
> 
> 
> I'll look into it.


Works for me:

qdisc tbf 8001: root rate 1000bit burst 10b/8 mpu 0b lat 720.0ms
  Sent 0 bytes 0 pkt (dropped 9, overlimits 0 requeues 0)
  rate 0bit 0pps backlog 0b 0p requeues 0

Packets are dropped as expected.
