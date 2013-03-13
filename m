From: Adam Jacob Muller <netdev@adam.gs>
Subject: r8169 and flapping links
Date: Wed, 13 Mar 2013 02:05:34 -0400
Message-ID: <5140172E.1030605@adam.gs>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from adam.gs ([64.188.63.86]:52989 "EHLO acheron.adam.gs"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752187Ab3CMGPU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Mar 2013 02:15:20 -0400
Received: from [127.0.0.1] (localhost [127.0.0.1])
	by acheron.adam.gs (Postfix) with ESMTP id 8B383D01E18
	for <netdev@vger.kernel.org>; Wed, 13 Mar 2013 02:05:35 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
I have a pair of RTL8168B-based network cards with SFP's installed in 
them (http://www.startech.com/~PEX1000SFP)

They have some extremely unusual behavior that I'm curious if anyone on 
the list has ever seen or could shed some light on.

Sometimes after bringing the network card up the network driver will 
continuously flap like:

r8169 0000:01:00.0 eth2: link down
r8169 0000:01:00.0 eth2: link up
r8169 0000:01:00.0 eth2: link down
r8169 0000:01:00.0 eth2: link up

The link is obviously not usable in that state.

On occasion though, some combination of down/up'ing the interface will 
actually bring things into a stable state and everything works well.

Interestingly, the hardware link light does not fluctuate while this 
happens.

I've tried with the kernel-based r8169 driver, and the r8168 driver from 
the Realtek site, but both exhibit the same behavior.

I do see a number of "similar" reports online regarding this issue, has 
anyone here seen anything like this before? Neither raising the module 
debug level to 16 and raising msglvl with ethool produced nothing 
interesting. Any suggestions on where to look for more debug (or a 
better list to ask, if this isn't the right place) would be much 
appreciated.

Thanks!

-Adam
