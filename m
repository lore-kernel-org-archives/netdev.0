From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH net-next v2] wan: dscc4: add checks for dma mapping errors
Date: Wed, 9 Aug 2017 13:45:48 +0300
Message-ID: <CAHp75VfAs8Bt2=qgN-foeTk7U+Y5WFFfm4bf4fWPk7kpLOU2Tg@mail.gmail.com>
References: <20170807215943.GA22433@electric-eye.fr.zoreil.com> <1502220499-18351-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Francois Romieu <romieu@fr.zoreil.com>,
        "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        ldv-project@linuxtesting.org
To: Alexey Khoroshilov <khoroshilov@ispras.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1502220499-18351-1-git-send-email-khoroshilov@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 8, 2017 at 10:28 PM, Alexey Khoroshilov
<khoroshilov@ispras.ru> wrote:
> The driver does not check if mapping dma memory succeed.
> The patch adds the checks and failure handling.
>
> Found by Linux Driver Verification project (linuxtesting.org).

Since it is going to be v3, just to mention that IIRC we better not to
use PCI DMA mapping API in favour of generic DMA mapping API.
Can you please double check this?


-- 
With Best Regards,
Andy Shevchenko
