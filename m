From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] xen-netback: fix some error return code
Date: Thu, 19 Dec 2013 14:59:35 -0500 (EST)
Message-ID: <20131219.145935.1730104240236887533.davem@davemloft.net>
References: <CAPgLHd_yD=s0xKXop8T47hvxw2MZD9PHZ9tKKB+45Y5uOHNUVQ@mail.gmail.com>
	<1387203160.21086.1.camel@kazak.uk.xensource.com>
	<CAPgLHd9Q7A--LQnsMKt-Tt-FwrA3FC1Un3kwLRH5pc4Z3N2K7A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Ian.Campbell@citrix.com, wei.liu2@citrix.com,
	yongjun_wei@trendmicro.com.cn, xen-devel@lists.xenproject.org,
	netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35571 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755230Ab3LST7h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 14:59:37 -0500
In-Reply-To: <CAPgLHd9Q7A--LQnsMKt-Tt-FwrA3FC1Un3kwLRH5pc4Z3N2K7A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Tue, 17 Dec 2013 10:42:09 +0800

> 'err' is overwrited to 0 after maybe_pull_tail() call, so the error
> code was not set if skb_partial_csum_set() call failed. Fix to return
> error -EPROTO from those error handling case instead of 0.
> 
> Fixes: d52eb0d46f36 ('xen-netback: make sure skb linear area covers checksum field')
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> ---
> v1 -> v2: rebased and fixed the description

Applied and queued up for -stable.
