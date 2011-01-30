From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]netdev: add driver for enc424j600 ethernet chip on SPI
 bus
Date: Sun, 30 Jan 2011 04:01:00 -0800 (PST)
Message-ID: <20110130.040100.48496301.davem@davemloft.net>
References: <AANLkTiksJpnx3M=D=WPF1wGej4POEQG4No-S3efb_gNM@mail.gmail.com>
	<AANLkTi=h52CMtS_05XW8JgWQOSf8pnezH6R6_VVS5DtQ@mail.gmail.com>
	<20110130115516.GA8392@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: balaji.v@thotakaa.com, netdev@vger.kernel.org, mirqus@gmail.com,
	mohan@thotakaa.com, blue.cube@seznam.cz,
	lanconelli.claudio@eptar.com, sriram@thotakaa.com,
	vbalaji.acs@gmail.com
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46074
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753341Ab1A3MAZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Jan 2011 07:00:25 -0500
In-Reply-To: <20110130115516.GA8392@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Sun, 30 Jan 2011 12:55:16 +0100

> Balaji Venkatachalam <balaji.v@thotakaa.com> :
>> From: Balaji Venkatachalam <balaji.v@thotakaa.com>
>> Updated patch [V1.29] for Microchip enc424j600 ethernet chip controlled via SPI.
>> 
>> I tested it on my custom board with ARM9 (Freescale i.MX233) with
>> Kernel 2.6.31.14.
> [...]
>> 4. mapped enc424j600_dump_regs to eth_ops get_regs
> 
> There is some kind of misunderstanding.
> 
> See include/linux/ethtool.h
> [...]
> struct ethtool_ops {
>         int     (*get_settings)(struct net_device *, struct ethtool_cmd *);
>         int     (*set_settings)(struct net_device *, struct ethtool_cmd *);
>         void    (*get_drvinfo)(struct net_device *, struct ethtool_drvinfo *);
>         int     (*get_regs_len)(struct net_device *);
>         void    (*get_regs)(struct net_device *, struct ethtool_regs *, void *);
> 
> It should not even compile.

Balaji, please take care of your changes and do not rush this review
process like you seem to be doing.

If you're not even watching for compiler warnings and errors, I can
expect that you did exaclty zero functional testing of the changed
code.

That's simply unacceptable.
