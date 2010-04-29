From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 0/3] [RFC] ptp: IEEE 1588 clock support
Date: Thu, 29 Apr 2010 11:42:08 +0200
Message-ID: <20100429094208.GA6889@riccoc20.at.omicron.at>
References: <20100427091344.GA5086@riccoc20.at.omicron.at> <20100427102025.GA6471@riccoc20.at.omicron.at> <4BD6E837.2040505@grandegger.com> <4BD70EC9.7080004@grandegger.com> <20100428054706.GA4516@riccoc20.at.omicron.at> <4BD83D37.4060301@grandegger.com> <4BD846C7.1050006@grandegger.com> <20100429083833.GA4629@riccoc20.at.omicron.at> <4BD95048.7050606@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:49981 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932501Ab0D3RDs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 13:03:48 -0400
Received: by fg-out-1718.google.com with SMTP id 19so4461180fgg.1
        for <netdev@vger.kernel.org>; Fri, 30 Apr 2010 10:03:47 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4BD95048.7050606@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 29, 2010 at 11:24:24AM +0200, Wolfgang Grandegger wrote:
> I used these interrupt number fixes as well but it was not necessary for
> the actual net-next-2.6 tree. Need to check why? I remember some version
> dependent re-mapping code.

I argued on the ppc list with Scott Wood about adding dts files, one
for each of mpc8313 rev A, B, and C, but he advocated fixing this
problem in uboot instead. Is the fix in uboot, or in the kernel?

> That's missing to get the PPS signal output. But it should probably go
> to gianfar_ptp.c.

Well, this fix is specific to the mpc8313, but the gianfar_ptp driver
is for all eTECs. For example, I have the ptp code running on the
p2020rdb and p2020ds, too.

I don't think board fixups really belong in the PTP clock driver.

Just my 2 cents,
Richard
