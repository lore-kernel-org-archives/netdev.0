From: Joel Stanley <joel@jms.id.au>
Subject: Re: [PATCH 2/2] net: phy: broadcom: Add support for BCM54612E
Date: Sat, 22 Oct 2016 11:10:57 +1030
Message-ID: <CACPK8XctEBjeYF0NU7QNH=A6qQOkusgnFpgOLOiJQpfOOdCeMQ@mail.gmail.com>
References: <1477070413-92621-1-git-send-email-xow@google.com> <1477070413-92621-3-git-send-email-xow@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Fainelli <f.fainelli@gmail.com>, davem@davemloft.net,
        jaedon.shin@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        OpenBMC Maillist <openbmc@lists.ozlabs.org>
To: Xo Wang <xow@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1477070413-92621-3-git-send-email-xow@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 22, 2016 at 3:50 AM, Xo Wang <xow@google.com> wrote:
> This PHY has internal delays enabled after reset. This clears the
> internal delay enables unless the interface specifically requests them.
>
> Signed-off-by: Xo Wang <xow@google.com>

Reviewed-by: Joel Stanley <joel@jms.id.au>

Cheers,

Joel

> ---
>  drivers/net/phy/broadcom.c | 48 ++++++++++++++++++++++++++++++++++++++++++++++
>  include/linux/brcmphy.h    |  1 +
>  2 files changed, 49 insertions(+)
