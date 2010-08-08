From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH 32/42] drivers/net/bnx2x: Adjust confusing if
 indentation
Date: Sun, 8 Aug 2010 22:13:05 +0300
Message-ID: <1281294785.21680.3.camel@lb-tlvb-eilong.il.broadcom.com>
References: <Pine.LNX.4.64.1008052226210.31692@ask.diku.dk>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
	yanivr@broadcom.com
To: "Julia Lawall" <julia@diku.dk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.1008052226210.31692@ask.diku.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-08-05 at 13:26 -0700, Julia Lawall wrote:
> From: Julia Lawall <julia@diku.dk>
> 
> Outdent the code following the if.
> 
> The semantic match that finds this problem is as follows:
> (http://coccinelle.lip6.fr/)
> 
> // <smpl>
> @r disable braces4@
> position p1,p2;
> statement S1,S2;
> @@
> 
> (
> if (...) { ... }
> |
> if (...) S1@p1 S2@p2
> )
> 
> @script:python@
> p1 << r.p1;
> p2 << r.p2;
> @@
> 
> if (p1[0].column == p2[0].column):
>   cocci.print_main("branch",p1)
>   cocci.print_secs("after",p2)
> // </smpl>
> 
> Signed-off-by: Julia Lawall <julia@diku.dk>

Acked-by: Eilon Greenstein <eilong@broadcom.com>
> ---
> This patch doesn't change the semantics of the code.  But it might not be
> what is intended.

This is indeed just bad alignment, thanks for the fix
