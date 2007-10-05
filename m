From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH]: Third (final?) release of Sun Neptune driver
Date: Fri, 05 Oct 2007 12:55:04 -0400
Message-ID: <47066C68.2010703@garzik.org>
References: <20071005.031209.57156822.davem@davemloft.net> <200710051846.19965.netdev@axxeo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Ariel.Hendel@sun.com, greg.onufer@sun.com,
	Ashley.Saulsbury@sun.com, Matheos.Worku@sun.com
To: Ingo Oeser <netdev@axxeo.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:38787 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756372AbXJEQzI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Oct 2007 12:55:08 -0400
In-Reply-To: <200710051846.19965.netdev@axxeo.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ingo Oeser wrote:
> Hi David,
> 
> some minor nits.
> 
> Could this driver be split into more files. 8k lines per file
> is quite a lot. Although GCC might optimize it best this way :-)

gcc does optimize it better this way, but overall, it's maintainer's 
preference.  It's far easier for many to have everything in a single 
file, when editing.


> David Miller schrieb:
>> +#define nr64(reg)		readq(np->regs + (reg))
>> +#define nw64(reg, val)		writeq((val), np->regs + (reg))
>> +
>> +#define nr64_mac(reg)		readq(np->mac_regs + (reg))
>> +#define nw64_mac(reg, val)	writeq((val), np->mac_regs + (reg))
>> +
>> +#define nr64_ipp(reg)		readq(np->regs + np->ipp_off + (reg))
>> +#define nw64_ipp(reg, val)	writeq((val), np->regs + np->ipp_off + (reg))
>> +
>> +#define nr64_pcs(reg)		readq(np->regs + np->pcs_off + (reg))
>> +#define nw64_pcs(reg, val)	writeq((val), np->regs + np->pcs_off + (reg))
>> +
>> +#define nr64_xpcs(reg)		readq(np->regs + np->xpcs_off + (reg))
>> +#define nw64_xpcs(reg, val)	writeq((val), np->regs + np->xpcs_off + (reg))
> 
> Can these be static inline and get the "struct niu *np" passed?

We have to answer this every single time...  :)  it makes the code more 
readable, and this is common practice all over the place.

	Jeff



