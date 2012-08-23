From: Stanislav Yakovlev <stas.yakovlev@gmail.com>
Subject: Re: [PATCH] ipw2200: use is_zero_ether_addr() and is_broadcast_ether_addr()
Date: Fri, 24 Aug 2012 01:13:07 +0400
Message-ID: <CA++WF2Nv_qb_jAnxhiR+WMjD4nwa3hAwMOSNqNtxc1LDX9ouXQ@mail.gmail.com>
References: <CAPgLHd_K=bbQ=zpKY8kW3HCGeuE3GwCCQOAg+gJoFdCv9SnVrg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linville@tuxdriver.com, yongjun_wei@trendmicro.com.cn,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:36486 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934412Ab2HWVNI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 17:13:08 -0400
In-Reply-To: <CAPgLHd_K=bbQ=zpKY8kW3HCGeuE3GwCCQOAg+gJoFdCv9SnVrg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 23 August 2012 10:54, Wei Yongjun <weiyj.lk@gmail.com> wrote:
> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
>
> Using is_zero_ether_addr() and is_broadcast_ether_addr() instead of
> directly use memcmp() to determine if the ethernet address is all zeros.
>
> spatch with a semantic match is used to found this problem.
> (http://coccinelle.lip6.fr/)
>
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> ---
>  drivers/net/wireless/ipw2x00/ipw2200.c | 11 ++---------
>  1 file changed, 2 insertions(+), 9 deletions(-)

Looks fine, thanks.

Stanislav.
