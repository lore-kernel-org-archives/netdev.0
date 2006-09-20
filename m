From: Segher Boessenkool <segher@kernel.crashing.org>
Subject: Re: [PATCH] Remove powerpc specific parts of 3c509 driver
Date: Wed, 20 Sep 2006 22:06:32 +0200
Message-ID: <82BFB659-DCB3-477C-B53D-4D8C55BAADB7@kernel.crashing.org>
References: <20060919145433.8fc7d478.sfr@canb.auug.org.au> <20060919184243.GL29167@austin.ibm.com> <45103C62.4080003@genesi-usa.com> <1158708269.6002.186.camel@localhost.localdomain> <488875E7-CCBC-47E1-A273-A2D037A997B2@kernel.crashing.org> <45109203.6060606@pobox.com> <1192ED41-329C-4CB0-AD87-B3BF62EC4337@kernel.crashing.org> <451096FE.1000104@pobox.com>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Matt Sealey <matt@genesi-usa.com>, akpm@osdl.org,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	ppc-dev <linuxppc-dev@ozlabs.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-in-02.arcor-online.net ([151.189.21.42]:37562 "EHLO
	mail-in-02.arcor-online.net") by vger.kernel.org with ESMTP
	id S1750707AbWITUGq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Sep 2006 16:06:46 -0400
In-Reply-To: <451096FE.1000104@pobox.com>
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>>> Sure, PCI busses are little-endian.  But is readX()/writeX() for  
>>>> PCI
>>>> only?
>>>
>>> Yes.
>>>
>>> For other buses, use foo_writel(), etc.
>> Can this please be documented then?  Never heard this before...
>
> You have come late to the party.

WHat do you mean here?  Could you please explain?

> This has been the case for many, many years.

No, it was never documented AFAICS.

> And there is no point in a massive rename to pci_writel(), either.

That would be really inconvenient, sure.  It's also inconvenient
that all the nice short names are PCI-only.


Segher

