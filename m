From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] Remove powerpc specific parts of 3c509 driver
Date: Tue, 19 Sep 2006 21:18:54 -0400
Message-ID: <451096FE.1000104@pobox.com>
References: <20060919145433.8fc7d478.sfr@canb.auug.org.au> <20060919184243.GL29167@austin.ibm.com> <45103C62.4080003@genesi-usa.com> <1158708269.6002.186.camel@localhost.localdomain> <488875E7-CCBC-47E1-A273-A2D037A997B2@kernel.crashing.org> <45109203.6060606@pobox.com> <1192ED41-329C-4CB0-AD87-B3BF62EC4337@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Matt Sealey <matt@genesi-usa.com>, akpm@osdl.org,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	ppc-dev <linuxppc-dev@ozlabs.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:44746 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1750839AbWITBTI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 21:19:08 -0400
To: Segher Boessenkool <segher@kernel.crashing.org>
In-Reply-To: <1192ED41-329C-4CB0-AD87-B3BF62EC4337@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Segher Boessenkool wrote:
>>> Sure, PCI busses are little-endian.  But is readX()/writeX() for PCI
>>> only?
>>
>> Yes.
>>
>> For other buses, use foo_writel(), etc.
> 
> Can this please be documented then?  Never heard this before...

You have come late to the party.  This has been the case for many, many 
years.

And there is no point in a massive rename to pci_writel(), either.

	Jeff



