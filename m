From: chriss <mail_to_chriss@gmx.net>
Subject: Re: 2.6.37 regression: adding main interface to a bridge breaks vlan interface RX
Date: Sun, 6 Feb 2011 19:37:41 +0000 (UTC)
Message-ID: <loom.20110206T203347-475@post.gmane.org>
References: <4D32FC1C.3010905@simon.arlott.org.uk> <201101231845.20505.maciej.rutecki@gmail.com> <AANLkTimTz=kMmJ=YhyJv28WUrsbN=ygBt9e7dMJ3KGqB@mail.gmail.com> <201101241625.45367.maciej.rutecki@gmail.com> <loom.20110205T163216-459@post.gmane.org> <AANLkTi=-+1dnh5ab6nMwjwMx20jpirYyaASZ=dk4OExp@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:52659 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753866Ab1BFTh4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Feb 2011 14:37:56 -0500
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1PmAQi-00055o-KO
	for netdev@vger.kernel.org; Sun, 06 Feb 2011 20:37:52 +0100
Received: from HSI-KBW-109-193-065-201.hsi7.kabel-badenwuerttemberg.de ([109.193.65.201])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sun, 06 Feb 2011 20:37:52 +0100
Received: from mail_to_chriss by HSI-KBW-109-193-065-201.hsi7.kabel-badenwuerttemberg.de with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sun, 06 Feb 2011 20:37:52 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesse Gross <jesse <at> nicira.com> writes:

>
> You should either attached a bridge to a vlan device or stack a vlan
> device on the bridge port depending on what you are trying to achieve.
> 
> The bridge handler takes all packets of the device that it is attached
> to, so having a vlan also attached to the same device will not work.
> You may get different results on older kernels depending on what NIC
> you were using but that was a bug.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo <at> vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 


Hi and thanks for your reply

I tried that.

I had under 2.6.36.3 following combination:

eth1 in br0 -> all traffic without vlan id
eth1.3 -> traffic with vlan 3

with 2.6.37 i should do the following
eth1 in br0 -> traffic w/o vlans
and br0.3 -> traffic with vlan id 3

But still there is no rx for vlan 3.
Any suggestions? Or am i missing something?


regards

