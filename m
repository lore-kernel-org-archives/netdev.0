From: Greg Ungerer <gerg@snapgear.com>
Subject: Re: [PATCH 5/5] m68knommu: dont allocate unused interrupts
Date: Thu, 03 Apr 2008 19:34:41 +1000
Message-ID: <47F4A4B1.3000709@snapgear.com>
References: <20080402204417.597098190@linutronix.de> <20080402210104.745627947@linutronix.de> <47F47D9E.3080901@snapgear.com> <20080403074323.GA778@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	uclinux-dev@uclinux.org
To: Sebastian Siewior <bigeasy@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosted02.westnet.com.au ([203.10.1.213]:56437 "EHLO
	hosted02.westnet.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757143AbYDCJes (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2008 05:34:48 -0400
In-Reply-To: <20080403074323.GA778@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sebastian Siewior wrote:
> * Greg Ungerer | 2008-04-03 16:47:58 [+1000]:
>>> This is because we register & enable way more interrupt sources than we
>>> actually handle. FEC_ENET_RXF (packet received), FEC_ENET_TXF (packet
>>> trasmitted) and FEC_ENET_MII (mii command done) are handled by the ISR.
>>> In my case FEC_ENET_RXB caused this because it was not handled, registered 
>>> and
>>> rarely the only flag in the status reg. Registering an interrupt source 
>>> without
>>> enabling it is also pointless.
>>> This patch removes them all except the three that are handled by the isr.
>> After the last discussions on uclinux-dev about this I have
>> a patch virtualy identical to this prepared for inclusion
>> in the 2.6.26 merge window.
> 
> So you drop this one. Great. That's why I asked you about a devel tree.
> The latest uclinux patch is linux-2.6.24-uc0.patch.gz which does not
> contain such a fix. The latest dist snapshot patch is from 2008-03-05
> and is about 147 MiB. I took a look at the diffstat
> (9.67 KB/s) - `uClinux-dist-20070130-20080305.diffstat' saved
> and yes, there are some modifications to fec.c but 10KiB/sec take me
> forever. I stared leeching it. The CVS [1] has no linux-2.6 directory.
> Therefore I assumed that is the latest one.
> I've been browsing the mailing list archive and did not find anything
> close to it (I found multicast discussions for instance).
> 
> Could please Cc me in future on your m68k patches? I would setup a git
> tree and feed them there. Alternatively I would be pleased if you could
> give me a pointer to your quilt series since I'm obviously not clever
> enough to find it.

I don't keep a quilt series or a git tree currently.

I release periodically in the form of the -uc patch series.

Regards
Greg


> [1] http://cvs.uclinux.org/cgi-bin/cvsweb.cgi/uClinux-dist/
> 
>> Regards
>> Greg
> 
> Sebastian
> 


-- 
------------------------------------------------------------------------
Greg Ungerer  --  Chief Software Dude       EMAIL:     gerg@snapgear.com
SnapGear -- a Secure Computing Company      PHONE:       +61 7 3435 2888
825 Stanley St,                             FAX:         +61 7 3891 3630
Woolloongabba, QLD, 4102, Australia         WEB: http://www.SnapGear.com
