From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH]netdev: add driver for enc424j600 ethernet chip on SPI bus
Date: Sun, 30 Jan 2011 12:55:16 +0100
Message-ID: <20110130115516.GA8392@electric-eye.fr.zoreil.com>
References: <AANLkTinosxXKgfkqGKqCLGi8tWeP4xnT1P3kMRu51CvS@mail.gmail.com> <AANLkTi=WQ-o+D0NicpGBd_qcfivLYaix_CUGWi2Rd_Zv@mail.gmail.com> <AANLkTi=F7n3fXr1EopYgoXTWkX7Wtx7dCs0x-t36871J@mail.gmail.com> <20110124.150450.48527021.davem@davemloft.net> <AANLkTiksJpnx3M=D=WPF1wGej4POEQG4No-S3efb_gNM@mail.gmail.com> <AANLkTi=h52CMtS_05XW8JgWQOSf8pnezH6R6_VVS5DtQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, mirqus@gmail.com, mohan@thotakaa.com,
	blue.cube@seznam.cz, lanconelli.claudio@eptar.com,
	sriram@thotakaa.com, David Miller <davem@davemloft.net>,
	"vbalaji.acs" <vbalaji.acs@gmail.com>
To: Balaji Venkatachalam <balaji.v@thotakaa.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:44982 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753341Ab1A3L5T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Jan 2011 06:57:19 -0500
Content-Disposition: inline
In-Reply-To: <AANLkTi=h52CMtS_05XW8JgWQOSf8pnezH6R6_VVS5DtQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Balaji Venkatachalam <balaji.v@thotakaa.com> :
> From: Balaji Venkatachalam <balaji.v@thotakaa.com>
> Updated patch [V1.29] for Microchip enc424j600 ethernet chip controlled via SPI.
> 
> I tested it on my custom board with ARM9 (Freescale i.MX233) with
> Kernel 2.6.31.14.
[...]
> 4. mapped enc424j600_dump_regs to eth_ops get_regs

There is some kind of misunderstanding.

See include/linux/ethtool.h
[...]
struct ethtool_ops {
        int     (*get_settings)(struct net_device *, struct ethtool_cmd *);
        int     (*set_settings)(struct net_device *, struct ethtool_cmd *);
        void    (*get_drvinfo)(struct net_device *, struct ethtool_drvinfo *);
        int     (*get_regs_len)(struct net_device *);
        void    (*get_regs)(struct net_device *, struct ethtool_regs *, void *);

It should not even compile.

-- 
Ueimor
