From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: i40e: avoid null pointer dereference
Date: Thu, 19 May 2016 11:26:18 -0700 (PDT)
Message-ID: <20160519.112618.515295810053057625.davem@davemloft.net>
References: <1463517693-10333-1-git-send-email-xypron.glpk@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: xypron.glpk@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42176 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932794AbcESS0T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2016 14:26:19 -0400
In-Reply-To: <1463517693-10333-1-git-send-email-xypron.glpk@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Heinrich Schuchardt <xypron.glpk@gmx.de>
Date: Tue, 17 May 2016 22:41:33 +0200

> In function i40e_debug_aq parameter desc is assumed to be
> possibly NULL. Do not dereference it before checking the
> value.
> 
> Fixes: f905dd62be88 ("i40e/i40evf: add max buf len to aq debug print helper")
> Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>

I'll let Jeff pick this up.
