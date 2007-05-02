From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH v2] gianfar: Add I/O barriers when touching buffer descriptor ownership.
Date: Wed, 2 May 2007 15:20:25 -0500
Message-ID: <FA9554A4-5A7D-4E03-BE28-C4B6B80D9DB9@kernel.crashing.org>
References: <20070502195712.GA16541@ld0162-tx32.am.freescale.net> <F1B250DD-A472-470F-B3D0-EBB2F042E454@kernel.crashing.org> <4638F0C4.2000406@freescale.com>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Scott Wood <scottwood@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nommos.sslcatacombnetworking.com ([67.18.224.114]:19932 "EHLO
	nommos.sslcatacombnetworking.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1766941AbXEBUVK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2007 16:21:10 -0400
In-Reply-To: <4638F0C4.2000406@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On May 2, 2007, at 3:12 PM, Scott Wood wrote:

> Kumar Gala wrote:
>> I'd rather see a wmb() instead of eieio() to keep this code non- 
>> ppc  specific.  (also, we implement wmb as eieio, so I don't keep  
>> the  comment about it being too heavy, unless you mean generically).
>
> wmb() is a sync, smp_wmb() is an eieio.  Andy told me he would not  
> accept a sync in those spots.

Sorry, was looking at the iobarrier code.

> And the driver is already ppc-specific; it uses in/out_be32.

True, but its hidden behind the gfar_read/write accessors.

Your change is a bit more blatant.

- k
