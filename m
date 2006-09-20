From: Segher Boessenkool <segher@kernel.crashing.org>
Subject: Re: [PATCH] Remove powerpc specific parts of 3c509 driver
Date: Wed, 20 Sep 2006 03:08:25 +0200
Message-ID: <1192ED41-329C-4CB0-AD87-B3BF62EC4337@kernel.crashing.org>
References: <20060919145433.8fc7d478.sfr@canb.auug.org.au> <20060919184243.GL29167@austin.ibm.com> <45103C62.4080003@genesi-usa.com> <1158708269.6002.186.camel@localhost.localdomain> <488875E7-CCBC-47E1-A273-A2D037A997B2@kernel.crashing.org> <45109203.6060606@pobox.com>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Matt Sealey <matt@genesi-usa.com>, akpm@osdl.org,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	ppc-dev <linuxppc-dev@ozlabs.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-in-06.arcor-online.net ([151.189.21.46]:64954 "EHLO
	mail-in-01.arcor-online.net") by vger.kernel.org with ESMTP
	id S1750809AbWITBIn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Sep 2006 21:08:43 -0400
In-Reply-To: <45109203.6060606@pobox.com>
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> Sure, PCI busses are little-endian.  But is readX()/writeX() for PCI
>> only?
>
> Yes.
>
> For other buses, use foo_writel(), etc.

Can this please be documented then?  Never heard this before...


Segher

