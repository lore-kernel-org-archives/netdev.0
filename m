From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH RFC 2/3] [RFC] ARM: shmobile: r7s72100: Add clock for
 r7s72100-gether
Date: Mon, 16 Dec 2013 10:31:27 +0900
Message-ID: <20131216013127.GB3192@verge.net.au>
References: <1387095886-15163-1-git-send-email-horms+renesas@verge.net.au>
 <1387095886-15163-3-git-send-email-horms+renesas@verge.net.au>
 <52AE0EAB.5040808@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org, Magnus Damm <magnus.damm@gmail.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-sh-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <52AE0EAB.5040808@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Dec 15, 2013 at 11:18:51PM +0300, Sergei Shtylyov wrote:
> Hello.
> 
> On 12/15/2013 11:24 AM, Simon Horman wrote:
> 
> >Signed-off-by: Simon Horman <horms+renesas@verge.net.au>
> >---
> >  arch/arm/mach-shmobile/clock-r7s72100.c | 5 ++++-
> >  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> >diff --git a/arch/arm/mach-shmobile/clock-r7s72100.c b/arch/arm/mach-shmobile/clock-r7s72100.c
> >index 7b457ae..7bce0c1 100644
> >--- a/arch/arm/mach-shmobile/clock-r7s72100.c
> >+++ b/arch/arm/mach-shmobile/clock-r7s72100.c
> [...]
> >@@ -145,9 +146,10 @@ struct clk div4_clks[DIV4_NR] = {
> >  };
> >
> >  enum { MSTP47, MSTP46, MSTP45, MSTP44, MSTP43, MSTP42, MSTP41, MSTP40,
> >-	MSTP33,	MSTP_NR };
> >+	MSTP33,	MSTP74, MSTP_NR };
> 
>    Shouldn't MSTP74 be on a line of its own at the start of the *enum*?

Yes, thanks, I will fix that.
