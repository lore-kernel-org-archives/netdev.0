From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH 0/3] [RFC] ptp: IEEE 1588 clock support
Date: Thu, 29 Apr 2010 13:31:42 +0200
Message-ID: <4BD96E1E.8070200@grandegger.com>
References: <20100427091344.GA5086@riccoc20.at.omicron.at> <20100427102025.GA6471@riccoc20.at.omicron.at> <4BD6E837.2040505@grandegger.com> <4BD70EC9.7080004@grandegger.com> <20100428054706.GA4516@riccoc20.at.omicron.at> <4BD83D37.4060301@grandegger.com> <4BD846C7.1050006@grandegger.com> <20100429083833.GA4629@riccoc20.at.omicron.at> <4BD95048.7050606@grandegger.com> <20100429094208.GA6889@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:57469 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757540Ab0D3Riz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 13:38:55 -0400
In-Reply-To: <20100429094208.GA6889@riccoc20.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Richard Cochran wrote:
> On Thu, Apr 29, 2010 at 11:24:24AM +0200, Wolfgang Grandegger wrote:
>> I used these interrupt number fixes as well but it was not necessary for
>> the actual net-next-2.6 tree. Need to check why? I remember some version
>> dependent re-mapping code.
> 
> I argued on the ppc list with Scott Wood about adding dts files, one
> for each of mpc8313 rev A, B, and C, but he advocated fixing this
> problem in uboot instead. Is the fix in uboot, or in the kernel?

It seems to be fixed in u-boot:

  commit 7120c888101952b7e61b9e54bb42370904aa0e68
  Author: Kim Phillips <kim.phillips@freescale.com>
  Date:   Mon Oct 12 11:06:19 2009 -0500

    mpc83xx: mpc8313 - handle erratum IPIC1 (TSEC IRQ number swappage)
    
    mpc8313e erratum IPIC1 swapped TSEC interrupt ID numbers on rev. 1
    h/w (see AN3545).  The base device tree in use has rev. 1 ID numbers,
    so if on Rev. 2 (and higher) h/w, we fix them up here.
    
    Signed-off-by: Kim Phillips <kim.phillips@freescale.com>
    Reviewed-by: Roland Lezuo <roland.lezuo@chello.at>

>> That's missing to get the PPS signal output. But it should probably go
>> to gianfar_ptp.c.
> 
> Well, this fix is specific to the mpc8313, but the gianfar_ptp driver
> is for all eTECs. For example, I have the ptp code running on the
> p2020rdb and p2020ds, too.
> 
> I don't think board fixups really belong in the PTP clock driver.
> 
> Just my 2 cents,

I see, fine for me if setting those bits does not harm.

Wolfgang. 
