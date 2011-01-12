From: Vasanthakumar Thiagarajan <vasanth@atheros.com>
Subject: Re: [PATCH] [RFC] ath9k: Fix reporting of RX STBC streams to
	userspace
Date: Wed, 12 Jan 2011 10:52:28 +0530
Message-ID: <20110112052227.GE31650@vasanth-laptop>
References: <1294765194-30542-1-git-send-email-walle@corscience.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Luis Rodriguez <Luis.Rodriguez@Atheros.com>,
	Jouni Malinen <Jouni.Malinen@Atheros.com>,
	Vasanth Thiagarajan <Vasanth.Thiagarajan@Atheros.com>,
	Senthilkumar Balasubramanian
	<Senthilkumar.Balasubramanian@Atheros.com>,
	"linville@tuxdriver.com" <linville@tuxdriver.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"ath9k-devel@lists.ath9k.org" <ath9k-devel@lists.ath9k.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Bernhard Walle <walle@corscience.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1294765194-30542-1-git-send-email-walle@corscience.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 11, 2011 at 10:29:54PM +0530, Bernhard Walle wrote:
> While the driver reports
> 
>         ath: TX streams 2, RX streams: 2
> 
> in the kernel log (with ATH_DBG_CONFIG set in the debug module
> parameter), "iw list" only reported
> 
> [...]
>         Capabilities: 0x12ce
>                 HT20/HT40
>                 SM Power Save disabled
>                 RX HT40 SGI
>                 TX STBC
>                 RX STBC 1-streams
> [...]
> 
> The driver seems to set the value as flag while the iw tool interprets
> it as number. This patch fixes that.

Nope. hw supports STBC for one Spatial stream only.

Vasanth
