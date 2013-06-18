From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH v2] net: fec: Fix build for MCF5272
Date: Tue, 18 Jun 2013 13:23:13 -0300
Message-ID: <CAOMZO5DW_e33MbfJhNG0ouf5g5o04AF7UchD3xwJV30GLovoNg@mail.gmail.com>
References: <1371569885-9054-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, Frank Li <Frank.Li@freescale.com>,
	Jim Baxter <jim_baxter@mentor.com>
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1371569885-9054-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 18, 2013 at 12:38 PM, Guenter Roeck <linux@roeck-us.net> wrote:
> Commits 4c09eed9 (net: fec: Enable imx6 enet checksum acceleration) and
> baa70a5c (net: fec: enable pause frame to improve rx prefomance for 1G
> network) introduced functionality into the FEC driver which is not
> supported on MCF5272. The registers used to implement this functionality
> do not exist on MCF5272. Since register defines for MCF5272 are separate
> from register defines for other chips, building images for MCF5272 fails,
> complaining about several undefined symbols.
>
> Adding the missing register defines is not an option, since the registers
> do not exist on MCF5272. Disable the added functionality for MCF5272 builds.

Can you please show the build error message you got?

Also, it would be nice if FEC could be enabled by default on some m68k
defconfig, so that we could spot issues like this earlier.
