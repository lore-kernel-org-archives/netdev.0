From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: caif: use correct format specifier
Date: Mon, 01 Aug 2016 13:43:54 -0700 (PDT)
Message-ID: <20160801.134354.1594660458943826700.davem@davemloft.net>
References: <1469949590-19166-1-git-send-email-xypron.glpk@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dmitry.tarnyagin@lockless.no, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: xypron.glpk@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54768 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755141AbcHAUuN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Aug 2016 16:50:13 -0400
In-Reply-To: <1469949590-19166-1-git-send-email-xypron.glpk@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Heinrich Schuchardt <xypron.glpk@gmx.de>
Date: Sun, 31 Jul 2016 09:19:50 +0200

> %u is the wrong format specifier for int.
> size_t cannot be converted to int without possible
> loss of information.
> 
> So leave the result as size_t and use %zu as format specifier.
> 
> cf. Documentation/printk-formats.txt
> 
> Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>

Applied.
