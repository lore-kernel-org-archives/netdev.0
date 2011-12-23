From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [net-next] stmmac: fix missing module license in the main.
Date: Fri, 23 Dec 2011 12:16:20 +0100
Message-ID: <4EF46304.8070806@st.com>
References: <4EF3DB45.30401@xenotime.net> <1324636267-25533-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030208080706080200000805"
Cc: netdev@vger.kernel.org, Randy Dunlap <rdunlap@xenotime.net>,
	LKML <linux-kernel@vger.kernel.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	"David S. Miller" <davem@davemloft.net>
To: linux-next@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1324636267-25533-1-git-send-email-peppe.cavallaro@st.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030208080706080200000805
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Sorry I had forgotten to add you on copy.

Peppe

p.s. patch attached here too.

On 12/23/2011 11:31 AM, Giuseppe CAVALLARO wrote:
> This patch fixes the following warning raised
> when compile:
> 
> WARNING: modpost: missing MODULE_LICENSE()
> in drivers/net/ethernet/stmicro/stmmac/stmmac.o
> 
> Reported-by: Randy Dunlap <rdunlap@xenotime.net>
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> ---
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index b314592..3738b47 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -2039,3 +2039,7 @@ err:
>  
>  __setup("stmmaceth=", stmmac_cmdline_opt);
>  #endif
> +
> +MODULE_DESCRIPTION("STMMAC 10/100/1000 Ethernet device driver");
> +MODULE_AUTHOR("Giuseppe Cavallaro <peppe.cavallaro@st.com>");
> +MODULE_LICENSE("GPL");



--------------030208080706080200000805
Content-Type: text/x-patch;
 name="0001-stmmac-fix-missing-module-license-in-the-main.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-stmmac-fix-missing-module-license-in-the-main.patch"

>From c24fa5e2784f85e6170a495bc42dea9a854cb3da Mon Sep 17 00:00:00 2001
From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Date: Fri, 23 Dec 2011 11:25:13 +0100
Subject: [net-next] stmmac: fix missing module license in the main.

This patch fixes the following warning raised
when compile:

WARNING: modpost: missing MODULE_LICENSE()
in drivers/net/ethernet/stmicro/stmmac/stmmac.o

Reported-by: Randy Dunlap <rdunlap@xenotime.net>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index b314592..3738b47 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2039,3 +2039,7 @@ err:
 
 __setup("stmmaceth=", stmmac_cmdline_opt);
 #endif
+
+MODULE_DESCRIPTION("STMMAC 10/100/1000 Ethernet device driver");
+MODULE_AUTHOR("Giuseppe Cavallaro <peppe.cavallaro@st.com>");
+MODULE_LICENSE("GPL");
-- 
1.7.4.4


--------------030208080706080200000805--
