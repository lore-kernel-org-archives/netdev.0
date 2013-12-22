From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] bna: fix sparse non static symbol warnings
Date: Sat, 21 Dec 2013 22:04:22 -0500 (EST)
Message-ID: <20131221.220422.1098607552319603178.davem@davemloft.net>
References: <CAPgLHd_dx9YdxMrrCybiEovXCfuGGg0TE+rvap3XpmyezuO+wQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rmody@brocade.com, yongjun_wei@trendmicro.com.cn,
	netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48667 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751583Ab3LVDEY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Dec 2013 22:04:24 -0500
In-Reply-To: <CAPgLHd_dx9YdxMrrCybiEovXCfuGGg0TE+rvap3XpmyezuO+wQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Sat, 21 Dec 2013 16:40:55 +0800

> -		fwimg_size = BFI_FLASH_IMAGE_SZ/sizeof(u32);
> +		fwimg_size = bfa_nw_ioc_flash_img_get_size(ioc);

This is not documented in your commit message and seems totally
unrelated to fixing sparse warnings.

I'm not applying this, sorry.
