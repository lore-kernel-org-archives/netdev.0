From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCHv1 1/7] TAP: Refactoring macvtap.c
Date: Sat, 7 Jan 2017 01:12:38 +0200
Message-ID: <CAHp75VeXGW6MC7_ATwiXvHpO1qPkYEOrVZdbRy0K1HxM1_tTEw@mail.gmail.com>
References: <1483742009-19184-1-git-send-email-sainath.grandhi@intel.com> <1483742009-19184-2-git-send-email-sainath.grandhi@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>, mahesh@bandewar.net,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Sainath Grandhi <sainath.grandhi@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1483742009-19184-2-git-send-email-sainath.grandhi@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 7, 2017 at 12:33 AM, Sainath Grandhi
<sainath.grandhi@intel.com> wrote:
> macvtap module has code for tap/queue management and link management. This patch splits
> the code into macvtap_main.c for link management and tap.c for tap/queue management.
> Functionality in tap.c can be re-used for implementing tap on other virtual interfaces.
>
> Signed-off-by: Sainath Grandhi <sainath.grandhi@intel.com>
> Tested-by: Sainath Grandhi <sainath.grandhi@intel.com>
> ---
>  drivers/net/Makefile       |    2 +
>  drivers/net/macvtap.c      | 1374 --------------------------------------------
>  drivers/net/macvtap_main.c |  218 +++++++
>  drivers/net/tap.c          | 1186 ++++++++++++++++++++++++++++++++++++++
>  include/linux/if_macvtap.h |   10 +
>  5 files changed, 1416 insertions(+), 1374 deletions(-)
>  delete mode 100644 drivers/net/macvtap.c
>  create mode 100644 drivers/net/macvtap_main.c
>  create mode 100644 drivers/net/tap.c
>  create mode 100644 include/linux/if_macvtap.h

Can you use -M -C for better view of this change? It's really hard to review.


-- 
With Best Regards,
Andy Shevchenko
