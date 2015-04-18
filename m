From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [PATCH] mac802154: llsec: fix return value check in
 llsec_key_alloc()
Date: Sat, 18 Apr 2015 15:02:39 +0200
Message-ID: <20150418130235.GA1297@omega>
References: <1429186594-20372-1-git-send-email-weiyj_lk@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Marcel Holtmann <marcel@holtmann.org>,
	"David S. Miller" <davem@davemloft.net>,
	Wei Yongjun <yongjun_wei@trendmicro.com.cn>,
	linux-wpan@vger.kernel.org, netdev@vger.kernel.org
To: weiyj_lk@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:36560 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752187AbbDRNCs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Apr 2015 09:02:48 -0400
Content-Disposition: inline
In-Reply-To: <1429186594-20372-1-git-send-email-weiyj_lk@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 16, 2015 at 08:16:34PM +0800, weiyj_lk@163.com wrote:
> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> In case of error, the functions crypto_alloc_aead() and crypto_alloc_blkcipher()
> returns ERR_PTR() and never returns NULL. The NULL test in the return value check
> should be replaced with IS_ERR().
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Acked-by: Alexander Aring <alex.aring@gmail.com>

Marcel, can you please queue this patch? Thanks.

- Alex
