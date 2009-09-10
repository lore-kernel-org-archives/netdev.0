From: Timur Tabi <timur@freescale.com>
Subject: Re: [PATCH 2/3] ucc_geth: Rearrange some code to avoid forward declarations
Date: Thu, 10 Sep 2009 08:00:48 -0500
Message-ID: <4AA8F880.1000300@freescale.com>
References: <20090910020140.GB31083@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Andy Fleming <afleming@freescale.com>,
	Li Yang <leoli@freescale.com>,
	Kumar Gala <galak@kernel.crashing.org>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Anton Vorontsov <avorontsov@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:43511 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752787AbZIJNBO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2009 09:01:14 -0400
Received: from de01smr01.freescale.net (de01smr01.freescale.net [10.208.0.31])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id n8AD15Me022328
	for <netdev@vger.kernel.org>; Thu, 10 Sep 2009 06:01:06 -0700 (MST)
Received: from az33exm25.fsl.freescale.net (az33exm25.am.freescale.net [10.64.32.16])
	by de01smr01.freescale.net (8.13.1/8.13.0) with ESMTP id n8AD2lof018746
	for <netdev@vger.kernel.org>; Thu, 10 Sep 2009 08:02:47 -0500 (CDT)
In-Reply-To: <20090910020140.GB31083@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Anton Vorontsov wrote:
> We'll need ugeth_disable() and ugeth_enable() calls earlier in the
> file, so rearrange some code to avoid forward declarations.
> 
> The patch doesn't contain any functional changes.
> 
> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>

Acked-by: Timur Tabi <timur@freescale.com>

I'm generally not qualified to review ucc_geth patches, but I'm in favor of this one.  I hate forward declarations.

-- 
Timur Tabi
Linux kernel developer at Freescale
