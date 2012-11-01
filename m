From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 4/4] arm/dts: am33xx: Add CPSW and MDIO module nodes
 for AM33XX
Date: Thu, 1 Nov 2012 08:45:08 +0100
Message-ID: <20121101074508.GA2637@netboy.at.omicron.at>
References: <1351498881-32482-1-git-send-email-hvaibhav@ti.com>
 <1351498881-32482-6-git-send-email-hvaibhav@ti.com>
 <50914107.2090909@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vaibhav Hiremath <hvaibhav@ti.com>, netdev@vger.kernel.org,
	paul@pwsan.com, linux-arm-kernel@lists.infradead.org,
	linux-omap@vger.kernel.org, Mugunthan V N <mugunthanvnm@ti.com>
To: Benoit Cousson <b-cousson@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:62809 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754222Ab2KAHpU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2012 03:45:20 -0400
Content-Disposition: inline
In-Reply-To: <50914107.2090909@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 31, 2012 at 04:17:27PM +0100, Benoit Cousson wrote:
> > +			compatible = "ti,cpsw";
> > +			ti,hwmods = "cpgmac0";
> > +			cpdma_channels = <8>;
> > +			host_port_no = <0>;
> > +			cpdma_reg_ofs = <0x800>;
> > +			cpdma_sram_ofs = <0xa00>;
> > +			ale_reg_ofs = <0xd00>;
> > +			ale_entries = <1024>;
> > +			host_port_reg_ofs = <0x108>;
> > +			hw_stats_reg_ofs = <0x900>;
> > +			bd_ram_ofs = <0x2000>;
> > +			bd_ram_size = <0x2000>;
> > +			no_bd_ram = <0>;
> > +			rx_descs = <64>;
> > +			mac_control = <0x20>;
> 
> Do you have to store all these data in the DTS? Cannot it be in the driver?
> 
> Do you expect to have several instance of the same IP with different
> parameters here?

As I understand it, there are only two different layouts for the CPSW,
the one in the dm814x and the one in the am335x. So I think it would
work to put only the version register offet in the DT, and the let the
driver figure out the rest from there.

But if TI is planning on reordering the registers with each new
silicon revision, again and again, then it might make sense to keep
the offsets in the DT.

[ I really wonder why the hardware people think that reshuffling the
  register layout constitutes an improvement. ]

Thanks,
Richard
