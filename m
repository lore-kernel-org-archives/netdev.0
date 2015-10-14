From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] mISDN: use kstrdup() in dsp_pipeline_build
Date: Tue, 13 Oct 2015 18:30:26 -0700 (PDT)
Message-ID: <20151013.183026.1058494354111432068.davem@davemloft.net>
References: <1444504930.8012.19.camel@perches.com>
	<01134401b5d955b4dd794562d85608db4fb8ba21.1444666330.git.geliangtang@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, isdn@linux-pingi.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: geliangtang@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55211 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752295AbbJNBOY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2015 21:14:24 -0400
In-Reply-To: <01134401b5d955b4dd794562d85608db4fb8ba21.1444666330.git.geliangtang@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Geliang Tang <geliangtang@163.com>
Date: Mon, 12 Oct 2015 01:19:07 -0700

> Use kstrdup instead of strlen-kmalloc-strcpy. Remove unneeded NULL
> test, it will be tested inside kstrdup. Remove 0 length string test,
> it has been tested in the caller of dsp_pipeline_build.
> 
> Signed-off-by: Geliang Tang <geliangtang@163.com>
> ---
> Changes in v2:
>   - Remove unneeded NULL test.

Applied, thanks.
