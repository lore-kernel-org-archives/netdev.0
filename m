From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Subject: Re: [PATCH 16/20] drivers/net/ethernet/renesas/sh_eth.c: fix error
 return code
Date: Thu, 04 Oct 2012 09:52:05 +0900
Message-ID: <506CDDB5.5080508@renesas.com>
References: <1349281090-10013-15-git-send-email-peter.senna@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kernel-janitors@vger.kernel.org,
	yoshihiro.shimoda.uh@renesas.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Peter Senna Tschudin <peter.senna@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <1349281090-10013-15-git-send-email-peter.senna@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Peter Senna Tschudin さんは書きました:
> From: Peter Senna Tschudin <peter.senna@gmail.com>
> 
> Convert a nonnegative error return code to a negative one, as returned
> elsewhere in the function.
> 
> A simplified version of the semantic match that finds this problem is as
> follows: (http://coccinelle.lip6.fr/)
> 
> // <smpl>
> (
> if@p1 (\(ret < 0\|ret != 0\))
>  { ... return ret; }
> |
> ret@p1 = 0
> )
> ... when != ret = e1
>     when != &ret
> *if(...)
> {
>   ... when != ret = e2
>       when forall
>  return ret;
> }
> // </smpl>
> 
> Signed-off-by: Peter Senna Tschudin <peter.senna@gmail.com>

Acked-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
