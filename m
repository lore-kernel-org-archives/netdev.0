From: Joe Perches <joe@perches.com>
Subject: Re: [RFC PATCH linux-next] et131x: Promote staging et131x driver to
 drivers/net
Date: Mon, 22 Sep 2014 18:57:25 -0700
Message-ID: <1411437445.2952.61.camel@joe-AO725>
References: <1411421283-25073-1-git-send-email-mark.einon@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	devel@driverdev.osuosl.org
To: Mark Einon <mark.einon@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1411421283-25073-1-git-send-email-mark.einon@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-09-22 at 22:28 +0100, Mark Einon wrote:
> This patch moves the et131x gigabit ethernet driver from drivers/staging
> to drivers/net/ethernet/agere.
> 
> There are no known issues at this time.

This doesn't apply to -next or -linux

[]
> This patch will only apply once the last few pending changes
> make their way from staging-next to linux-next, but posting
> now in the hope that feedback can be given and this change can
> make it in before the next merge window.n yo

When you do post the actual patch, can you please use
"git format-patch -M" so that the patch is significantly
smaller and the renames are obvious?

>  drivers/net/ethernet/Kconfig        |    1 +
>  drivers/net/ethernet/Makefile       |    1 +
>  drivers/net/ethernet/agere/Kconfig  |   31 +
>  drivers/net/ethernet/agere/Makefile |    5 +
>  drivers/net/ethernet/agere/et131x.c | 4412 +++++++++++++++++++++++++++++++++++
>  drivers/net/ethernet/agere/et131x.h | 1533 ++++++++++++
>  drivers/staging/Kconfig             |    2 -
>  drivers/staging/Makefile            |    1 -
>  drivers/staging/et131x/Kconfig      |   10 -
>  drivers/staging/et131x/Makefile     |    5 -
>  drivers/staging/et131x/README       |   15 -
>  drivers/staging/et131x/et131x.c     | 4412 -----------------------------------
>  drivers/staging/et131x/et131x.h     | 1533 ------------
>  13 files changed, 5983 insertions(+), 5978 deletions(-)
>  create mode 100644 drivers/net/ethernet/agere/Kconfig
>  create mode 100644 drivers/net/ethernet/agere/Makefile
>  create mode 100644 drivers/net/ethernet/agere/et131x.c
>  create mode 100644 drivers/net/ethernet/agere/et131x.h
>  delete mode 100644 drivers/staging/et131x/Kconfig
>  delete mode 100644 drivers/staging/et131x/Makefile
>  delete mode 100644 drivers/staging/et131x/README
>  delete mode 100644 drivers/staging/et131x/et131x.c
>  delete mode 100644 drivers/staging/et131x/et131x.h
