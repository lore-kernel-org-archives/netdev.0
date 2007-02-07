From: Timur Tabi <timur@freescale.com>
Subject: Re: [PATCH 1/4] ucc_geth: Change private immrbar_virt_to_phys to
 generic iopa
Date: Wed, 07 Feb 2007 10:43:53 -0600
Message-ID: <45CA01C9.3020309@freescale.com>
References: <45C86715.6090600@freescale.com> <001EB06E-FC1D-4F0A-A910-8E08EE0B8CE2@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Li Yang <leoli@freescale.com>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:48785 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965539AbXBGQn7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Feb 2007 11:43:59 -0500
In-Reply-To: <001EB06E-FC1D-4F0A-A910-8E08EE0B8CE2@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kumar Gala wrote:
> 
> On Feb 6, 2007, at 5:31 AM, Li Yang wrote:
> 
>> Get rid of private immrbar_virt_to_phys() routine and
>> use generic iopa().
> 
> Nack. iopa() isn't that generic, shouldn't we really be using the dma 
> mapping API here?

I'm having a hard time understanding what's wrong with iopa().  Is it because 
it's a 32-bit only function?  The memory has already been mapped with ioremap(), 
so why would we want to map it again?

-- 
Timur Tabi
Linux Kernel Developer @ Freescale
