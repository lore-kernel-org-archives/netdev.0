From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH 1/4] ucc_geth: Change private immrbar_virt_to_phys to generic iopa
Date: Wed, 7 Feb 2007 10:49:27 -0600
Message-ID: <AC7EDFBD-7282-460F-9D0E-2E3AA9ED7718@kernel.crashing.org>
References: <45C86715.6090600@freescale.com> <001EB06E-FC1D-4F0A-A910-8E08EE0B8CE2@kernel.crashing.org> <45CA01C9.3020309@freescale.com>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Li Yang <leoli@freescale.com>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Timur Tabi <timur@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nommos.sslcatacombnetworking.com ([67.18.224.114]:30373 "EHLO
	nommos.sslcatacombnetworking.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965684AbXBGQuy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Feb 2007 11:50:54 -0500
In-Reply-To: <45CA01C9.3020309@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Feb 7, 2007, at 10:43 AM, Timur Tabi wrote:

> Kumar Gala wrote:
>> On Feb 6, 2007, at 5:31 AM, Li Yang wrote:
>>> Get rid of private immrbar_virt_to_phys() routine and
>>> use generic iopa().
>> Nack. iopa() isn't that generic, shouldn't we really be using the  
>> dma mapping API here?
>
> I'm having a hard time understanding what's wrong with iopa().  Is  
> it because it's a 32-bit only function?  The memory has already  
> been mapped with ioremap(), so why would we want to map it again?

If its been mapped with ioremap() you know the physical address  
already so why do you need iopa().  The problem I have is iopa() is  
ppc specific and I can envision a day when someone wants to run Linux  
on a StarCore + QE, so having the drivers using ppc specific APIs is  
bad.

- k
