From: Edgar E Iglesias <edgar.iglesias@axis.com>
Subject: Re: ipv4 ipsec
Date: Wed, 1 Jun 2005 02:02:59 +0200
Message-ID: <20050601000259.GA4742@edgar.se.axis.com>
References: <20050531224717.GE4068@edgar.se.axis.com> <20050531.155642.38710400.davem@davemloft.net> <20050531232340.GA4589@edgar.se.axis.com> <20050531.164741.116354448.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050531.164741.116354448.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, May 31, 2005 at 04:47:41PM -0700, David S. Miller wrote:
> From: Edgar E Iglesias <edgar.iglesias@axis.com>
> Date: Wed, 1 Jun 2005 01:23:40 +0200
> 
> > oh sorry, I hope I get it right this time :)
> 
> Your email client has mangled the tab characters into spaces
> in the patch, so the patch still will not apply correctly.
> 
> Please fix this.

One more try.. sorry

Best regards
-- 
        Programmer
        Edgar E Iglesias <edgar@axis.com> 46.46.272.1946

Signed-off-by: Edgar E Iglesias <edgar@axis.com>

-----

--- linux-2.6.11-gentoo-r6/net/ipv4/esp4.c	2005-04-14 21:39:32.000000000 +0200
+++ linux-2.6.11-gentoo-r9/net/ipv4/esp4.c	2005-06-01 00:38:55.000000000 +0200
@@ -480,7 +480,7 @@
 {
 	struct xfrm_decap_state decap;
 
-	if (sizeof(struct esp_decap_data)  <
+	if (sizeof(struct esp_decap_data)  >
 	    sizeof(decap.decap_data)) {
 		extern void decap_data_too_small(void);
 
