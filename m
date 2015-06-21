From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cxgb3: avoid needless buffer copy for firmware
Date: Sun, 21 Jun 2015 09:50:54 -0700 (PDT)
Message-ID: <20150621.095054.1961985059600092774.davem@davemloft.net>
References: <20150616223617.GA17958@www.outflux.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, santosh@chelsio.com,
	netdev@vger.kernel.org, agordeev@redhat.com, joe@perches.com
To: keescook@chromium.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46523 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754831AbbFUQjI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jun 2015 12:39:08 -0400
In-Reply-To: <20150616223617.GA17958@www.outflux.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kees Cook <keescook@chromium.org>
Date: Tue, 16 Jun 2015 15:36:17 -0700

> There's no reason to perform a buffer copy for the firmware name. This
> also avoids a (currently impossible with current callers) NULL dereference
> if there was no matching firmware.
> 
> Signed-off-by: Kees Cook <keescook@chromium.org>

Applied to net-next, thanks.
