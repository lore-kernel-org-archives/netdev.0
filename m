From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 03/10] net: smc91x: use io{read,write}*_rep
 accessors instead of string functions
Date: Mon, 10 Dec 2012 15:47:14 -0500 (EST)
Message-ID: <20121210.154714.1593095288525239001.davem@davemloft.net>
References: <1355166762-15133-1-git-send-email-will.deacon@arm.com>
	<1355166762-15133-4-git-send-email-will.deacon@arm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	benh@kernel.crashing.org, arnd@arndb.de, james.hogan@imgtec.com,
	nico@fluxnic.net, netdev@vger.kernel.org
To: will.deacon@arm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59787 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750826Ab2LJUrR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2012 15:47:17 -0500
In-Reply-To: <1355166762-15133-4-git-send-email-will.deacon@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Will Deacon <will.deacon@arm.com>
Date: Mon, 10 Dec 2012 19:12:35 +0000

> The {read,write}s{b,w,l} operations are not defined by all architectures
> and are being removed from the asm-generic/io.h interface.
> 
> This patch replaces the usage of these string functions in the default
> SMC accessors with io{read,write}{8,16,32}_rep calls instead, which are
> defined for all architectures.
> 
> Cc: Arnd Bergmann <arnd@arndb.de>
> Cc: Ben Herrenschmidt <benh@kernel.crashing.org>
> Cc: Nicolas Pitre <nico@fluxnic.net>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Will Deacon <will.deacon@arm.com>

Applied.
