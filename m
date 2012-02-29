From: "N, Mugunthan V" <mugunthanvnm@ti.com>
Subject: RE: [PATCH v4 2/2] netdev: driver: ethernet: Add TI CPSW driver
Date: Wed, 29 Feb 2012 16:28:48 +0000
Message-ID: <EB1619762EAF8B4E97A227FB77B7E02931793847@DBDE01.ent.ti.com>
References: <1330490737-28973-1-git-send-email-mugunthanvnm@ti.com>
	<1330490737-28973-3-git-send-email-mugunthanvnm@ti.com>
 <87pqcxdbmp.fsf@macbook.be.48ers.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Peter Korsgaard <jacmet@sunsite.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:38900 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030302Ab2B2Q3F convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Feb 2012 11:29:05 -0500
In-Reply-To: <87pqcxdbmp.fsf@macbook.be.48ers.dk>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Peter Korsgaard

> -----Original Message-----
> From: Peter Korsgaard [mailto:jacmet@gmail.com] On Behalf Of Peter
> Korsgaard
> Sent: Wednesday, February 29, 2012 6:45 PM
> To: N, Mugunthan V
> Cc: netdev@vger.kernel.org; davem@davemloft.net
> Subject: Re: [PATCH v4 2/2] netdev: driver: ethernet: Add TI CPSW driver
> 
> >>>>> "M" == Mugunthan V N <mugunthanvnm@ti.com> writes:
> 
> Hi,
> 
[...]
>  M> +++ b/include/linux/platform_data/cpsw.h
[...]
> 
> Is this really platform specific data (rather than SoC specific)? If
> it's purely a difference between 335x and 814x just use an id_table with
> different platform device names instead.

Instead of driver maintaining the SoC specific offsets, SoC specific files in arch/arm/mach-omap2/ can hold this. Another reason is currently this IP is present in 2 SoCs, there are other SoC coming up where the offsets may change.

> 
> --
> Bye, Peter Korsgaard

With regards
Mugunthan V N
