From: Baruch Siach <baruch@tkos.co.il>
Subject: Re: Segmentation fault when using ping6
Date: Thu, 7 Oct 2010 07:32:03 +0200
Message-ID: <20101007053202.GA27250@jasper.tkos.co.il>
References: <4CACDBB1.9050305@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Rogerio Pimentel <rogerio.pimentel@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tango.tkos.co.il ([62.219.50.35]:33602 "EHLO tango.tkos.co.il"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751471Ab0JGFci (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Oct 2010 01:32:38 -0400
Content-Disposition: inline
In-Reply-To: <4CACDBB1.9050305@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Rogerio,

On Wed, Oct 06, 2010 at 05:27:29PM -0300, Rogerio Pimentel wrote:
> I'm having a "segmentation fault" problem when using ping6.
> 
> When testing on ARM9 platforms (i.MX25 and i.MX27), it returns the error:
> 
> root@freescale ~$ ping6 ::1
> PING ::1 (::1): 56 data bytes
> Segmentation fault
> 
> When testing on ARM11 and ARM Cortex A8 platforms (i.MX31 and
> i.MX51), it works:
> 
> root@freescale ~$ ping6 ::1
> PING ::1 (::1): 56 data bytes
> 64 bytes from ::1: seq=0 ttl=64 time=0.331 ms
> 64 bytes from ::1: seq=1 ttl=64 time=0.214 ms
> 64 bytes from ::1: seq=2 ttl=64 time=0.176 ms
> 64 bytes from ::1: seq=3 ttl=64 time=0.155 ms
> 
> On all cases, I'm using Linux Kernel 2.6.35 (from Mainline) and
> Busybox 1.15.0
> 
> Does anybody have any idea?

This seems to be a Busybox related issue. I'd suggests you to try the latest 
version of Busybox (1.17.2), and if the problem persists, ask at the Busybox 
mailing list. Don't forget to add strace output to your message.

baruch

-- 
                                                     ~. .~   Tk Open Systems
=}------------------------------------------------ooO--U--Ooo------------{=
   - baruch@tkos.co.il - tel: +972.2.679.5364, http://www.tkos.co.il -
