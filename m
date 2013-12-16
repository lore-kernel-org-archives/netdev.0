From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] drivers: ptp: Include new header file in ptp_pch.c
Date: Mon, 16 Dec 2013 09:58:40 +0100
Message-ID: <20131216085839.GA8303@netboy>
References: <1387140255-11797-1-git-send-email-rashika.kheria@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Darren Hart <dvhart@linux.intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Joe Perches <joe@perches.com>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	Veaceslav Falico <vfalico@redhat.com>, netdev@vger.kernel.org,
	josh@joshtriplett.org
To: Rashika Kheria <rashika.kheria@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1387140255-11797-1-git-send-email-rashika.kheria@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 16, 2013 at 02:14:15AM +0530, Rashika Kheria wrote:
> ---
>  drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h    |    9 ---------
>  .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   |    1 +
>  drivers/ptp/ptp_pch.c                              |    1 +
>  include/linux/ptp_pch.h                            |   16 ++++++++++++++++
>  4 files changed, 18 insertions(+), 9 deletions(-)
>  create mode 100644 include/linux/ptp_pch.h

Instead of adding a random driver header into include/linux, I would
prefer that you just move the ptp_pch.c from drivers/ptp to
drivers/net/ethernet/oki-semi/pch_gbe. Then you can just include
pch_gbe.h directly.

Thanks,
Richard
