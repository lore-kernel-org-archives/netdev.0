From: renevant@internode.on.net
Subject: ax88179 regression
Date: Sat, 08 Feb 2014 12:56:10 +1100
Message-ID: <1890496.0JLCYTPnkG@athas>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ipmail06.adl2.internode.on.net ([150.101.137.129]:36821 "EHLO
	ipmail06.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750916AbaBHB41 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Feb 2014 20:56:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I have finally nailed down my other issues and i'm at a point where I can 
bisect from a point that is 100% stable and working.


I am currently running a kernel checked out at commit 
d194c031994d3fc1038fa09e9e92d9be24a21921 

A point in 3.12rc4

At this point the ax88179 works without issue even with scatter gather turned 
on. So somewhere from this point something goes wrong and there is some 
condition that exists that can lock up the nic.


I will keep bisecting at report my findings.


Regards,

Will Trives
