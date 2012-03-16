From: "N, Mugunthan V" <mugunthanvnm@ti.com>
Subject: RE: [PATCH v4 2/2] netdev: driver: ethernet: Add TI CPSW driver
Date: Fri, 16 Mar 2012 10:21:40 +0000
Message-ID: <EB1619762EAF8B4E97A227FB77B7E029317AD881@DBDE01.ent.ti.com>
References: <1330490737-28973-1-git-send-email-mugunthanvnm@ti.com>
	<1330490737-28973-3-git-send-email-mugunthanvnm@ti.com>
	<87pqcxdbmp.fsf@macbook.be.48ers.dk>
	<EB1619762EAF8B4E97A227FB77B7E02931793847@DBDE01.ent.ti.com>
 <87zkc0783i.fsf@macbook.be.48ers.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Peter Korsgaard <jacmet@sunsite.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:36251 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031136Ab2CPKV5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2012 06:21:57 -0400
In-Reply-To: <87zkc0783i.fsf@macbook.be.48ers.dk>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Peter

> -----Original Message-----
> From: Peter Korsgaard [mailto:jacmet@gmail.com] On Behalf Of Peter
> Korsgaard
> Sent: Thursday, March 01, 2012 7:10 PM
> To: N, Mugunthan V
> Cc: netdev@vger.kernel.org; davem@davemloft.net
> Subject: Re: [PATCH v4 2/2] netdev: driver: ethernet: Add TI CPSW driver
> 
> >>>>> "N" == N, Mugunthan V <mugunthanvnm@ti.com> writes:
> 
> Hi,
> 
>  >> Is this really platform specific data (rather than SoC specific)? If
>  >> it's purely a difference between 335x and 814x just use an id_table
> with
>  >> different platform device names instead.
> 
>  N> Instead of driver maintaining the SoC specific offsets, SoC specific
>  N> files in arch/arm/mach-omap2/ can hold this. Another reason is
>  N> currently this IP is present in 2 SoCs, there are other SoC coming
>  N> up where the offsets may change.
> 
> Sure, it's the same amount of code no matter where it gets put, but the
> idea is to move code from arch/arm to drivers/ where possible. This will
> also help if the IP is ever used on non-omap2 platforms and for device
> tree support.

Instead of keeping the SoC Specific data in driver keeping it in hwmod will
be fine and while supporting Device tree, driver will receive the same data
from device tree, so I will keep the offsets in hwmod itself.

> 
> --
> Bye, Peter Korsgaard
