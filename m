From: Jens Osterkamp <jens@de.ibm.com>
Subject: Re: spidernet: add improved phy support in sungem_phy.c
Date: Thu, 1 Feb 2007 11:54:49 +0100
Message-ID: <200702011154.49558.jens@de.ibm.com>
References: <200701261407.48237.jens@de.ibm.com> <200701262331.58491.jens@de.ibm.com> <20070126233809.GA16660@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Ishizaki Kou <kou.ishizaki@toshiba.co.jp>,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	cbe-oss-dev@ozlabs.org, Linas Vepstas <linas@austin.ibm.com>,
	jgarzik@pobox.com, James K Lewis <jim@jklewis.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.29.152]:34058 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422791AbXBAKyw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Feb 2007 05:54:52 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate3.de.ibm.com (8.13.8/8.13.8) with ESMTP id l11AspBH028116
	for <netdev@vger.kernel.org>; Thu, 1 Feb 2007 10:54:51 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l11Asog31495062
	for <netdev@vger.kernel.org>; Thu, 1 Feb 2007 11:54:50 +0100
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l11AsnJZ025681
	for <netdev@vger.kernel.org>; Thu, 1 Feb 2007 11:54:50 +0100
In-Reply-To: <20070126233809.GA16660@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Francois,

thank you for your comments. I'll send a revised patch soon.

> +#define BCM5421_MODE_MASK	1 << 5
> 
> Please add parenthesis.

Done.

> "&" is fine despite the lack of parenthesis above but it is error-prone.

Corrected.

> 
> +
> +	if ( mode == GMII_COPPER) {
>            ^^^
> +		return genmii_poll_link(phy);
> +	}
> 
> No curly-braces for single line statements please.

I corrected this on all my additions.

> Ternary operator ?

I dont like ternary operators. Yes, I know, they are cool, but
they make the code much less readable IMHO.

> +#define BCM5461_FIBER_LINK	1 << 2
> +#define BCM5461_MODE_MASK	3 << 1
> 
> Please add parenthesis.

Done.

> Join the dark side and use a ternary operator.

See above.

> +static int bcm5461_enable_fiber(struct mii_phy* phy, int autoneg)
> +{
> +	/*
> +	phy_write(phy, MII_NCONFIG, 0xfc0c);
> +	phy_write(phy, MII_BMCR, 0x4140);
> +	*/
> 
> Remove ?

Done.

Jens
