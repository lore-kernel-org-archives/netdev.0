From: Michael Chan <mchan@broadcom.com>
Subject: Re: [PATCH] drivers/net/ethernet/broadcom/bnx2.c
Date: Thu, 1 May 2014 10:39:35 -0700
Message-ID: <1398965975.3056.40.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <5361C29C.5060808@taghos.com.br>
	 <1398922768.3056.4.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	 <53627814.7090106@taghos.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset="cp1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: "Magnos A. Hammes" <magnos@taghos.com.br>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:24995 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751464AbaEARjm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2014 13:39:42 -0400
In-Reply-To: <53627814.7090106@taghos.com.br>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-05-01 at 13:36 -0300, Magnos A. Hammes wrote: 
> Ok, I cloned that git tree and used the firmwares available there, but 
> it didn't work with this firmware: bnx2/bnx2-mips-09-6.2.1b.fw sha1sum 
> 8f11b39a60a4e1dd3774a10218c913f1cb761353
> 

I have the same sha1 sum on the same firmware file on my system and it
works for me.

> It only works when I change the source code of 
> "drivers/net/ethernet/broadcom/bnx2.c" and compile the kernel again, 
> making him load this firmware "bnx2/bnx2-mips-09-6.2.1a.fw" instead of 
> "bnx2/bnx2-mips-09-6.2.1b.fw".

I don't see why it wouldn't work if both firmware files are in the same
location.  May be you have some udev rules that are preventing it?
> 
> 
