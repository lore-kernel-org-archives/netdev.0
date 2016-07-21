From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next] net: dsa: add CONFIG_NET_DSA_LEGACY
Date: Thu, 21 Jul 2016 02:35:45 +0200
Message-ID: <20160721003545.GB22834@lunn.ch>
References: <20160720222641.30899-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160720222641.30899-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 20, 2016 at 06:26:41PM -0400, Vivien Didelot wrote:
> This patch simply moves the legacy DSA code from dsa.c to legacy.c,
> except the few shared symbols which remain in dsa.c.

I think it is a bit early for this. Lets convert all in kernel users
to the new binding first.

> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
>  drivers/net/dsa/Kconfig          |    4 +-
>  drivers/net/dsa/mv88e6xxx/chip.c |    8 +
>  include/net/dsa.h                |    4 +
>  net/dsa/Kconfig                  |    8 +
>  net/dsa/Makefile                 |    1 +
>  net/dsa/dsa.c                    |  985 ------------------------------------
>  net/dsa/legacy.c                 | 1013 ++++++++++++++++++++++++++++++++++++++

I'm surprised git did not notice this is a rename.

    Andrew
