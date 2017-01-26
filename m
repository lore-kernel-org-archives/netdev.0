From: Rafal Ozieblo <rafalo@cadence.com>
Subject: RE: [PATCH] Fix 64 bit addressing support for GEM
Date: Thu, 26 Jan 2017 16:16:30 +0000
Message-ID: <BN3PR07MB2516DC52226DB57C29BC13F4C9770@BN3PR07MB2516.namprd07.prod.outlook.com>
References: <1485442837-26598-1-git-send-email-rafalo@cadence.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
To: Rafal Ozieblo <rafalo@cadence.com>,
        Nicolas Ferre <nicolas.ferre@atmel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "harinikatakamlinux@gmail.com" <harinikatakamlinux@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1485442837-26598-1-git-send-email-rafalo@cadence.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-----Original Message-----
> From: Rafal Ozieblo [mailto:rafalo@cadence.com]=20
> Sent: 26 stycznia 2017 16:01
> Subject: [PATCH] Fix 64 bit addressing support for GEM
>=20
> This patch adds support for 32 bit GEM in
> 64 bit system. It checks capability at runtime
> and uses appropriate buffer descriptor.
>=20
> Signed-off-by: Rafal Ozieblo <rafalo@cadence.com>
> ---
>  #ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
> -	if (GEM_BFEXT(DBWDEF, gem_readl(bp, DCFG1)) > GEM_DBW32)
> +	if (GEM_BFEXT(DAW64, gem_readl(bp, DCFG6))) {
> +		pr_emerg("rozieblo: 64B!\n");
I forgot to remove that log message.
