From: hayeswang <hayeswang@realtek.com>
Subject: RE: Realtek r8168C / r8169 driver VLAN TAG stripping
Date: Mon, 31 Jan 2011 13:45:48 +0800
Message-ID: <BFBA3A0B2A4B4E8B8798977086BFC4C9@realtek.com.tw>
References: <AANLkTimqkJ3DGBX5iREEcx6sgAM+2CZHNWMU+noNSitp@mail.gmail.com>     <20110116192017.GA3569@electric-eye.fr.zoreil.com>     <AANLkTi=uNKMj_gs_bKRQ1tQa0TMwdnyrtVcR5JPNpmJv@mail.gmail.com>     <AANLkTikoXfgHrJyMbe6A_HmvXT_QRo55w76st5Wo0hSv@mail.gmail.com>     <20110118012146.GA3704@electric-eye.fr.zoreil.com>     <AANLkTimA1C=trH+WGpBdPU=vBf-cN+xB4Br3+vJb-Qum@mail.gmail.com>     <20110127150744.GA7925@electric-eye.fr.zoreil.com>     <AANLkTi=OwsMO8x9AOy=MmohU4SSQcv+o=TvwNs0NNsQR@mail.gmail.com>     <20110127165031.GA7966@electric-eye.fr.zoreil.com>     <AANLkTin17BgJDdTbSMork8XEw4PVz_KrVBZvHdQwTRNH@mail.gmail.com> <20110128120624.GA8100@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, 'Ivan Vecera' <ivecera@redhat.com>
To: 'Francois Romieu' <romieu@fr.zoreil.com>,
	'Anand Raj Manickam' <anandrm@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:46779 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752092Ab1AaFqP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Jan 2011 00:46:15 -0500
In-Reply-To: <20110128120624.GA8100@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Reading my rev1.0 8168c datasheet from may 2007, when there 
> is no tx offload, no checksumming, the tx descriptor layout 
> should be the same as the perennial 8169 tx descriptor layout.
> 
> Either (1) the VLAN registers and descriptor layout is 
> different for this chipset or (2) something prevents the 
> register / descriptor write (read ?) to be completely 
> effective or (3) there is something beyond the 8168 or
> (4) there is a 8168 hardware bug.
> 
> 1 : Hayes may answer. You can give Realtek's own driver a try btw.
> 2 : Seen before. It could be a software or a (non-8168) hardware one.
>     I have no idea if your hardware setup includes a single card with
>     four ports or four independent cards with their own 8168 or worse.
> 3 : See the hardware setup part of (2).
> 4 : I don't hope so. Hayes may answer as well.
> 

I find nothing wrong for the source code of kernel. I think it should work. Only
the tx descriptor need to be set for the tx. For the receiving, the register
0xe0 (CPlusCmd) bit 6 (RxVlan) should be set. That is all. And I don't get any
information about hardware bug, so I really don't know what's wrong. I will
check it after the vacation of Chinese New Year.
 
Best Regards,
Hayes

