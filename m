From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [patch net v2] net: fec: fix compile with CONFIG_M5272
Date: Mon, 5 Dec 2016 08:02:10 -0200
Message-ID: <CAOMZO5A+tT6Ounrq8dhuE08AYWiPQ5C3yKKZVO-gbVYYnieoig@mail.gmail.com>
References: <1480925763-20254-1-git-send-email-nikita.yoush@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Fugang Duan <fugang.duan@nxp.com>,
        Troy Kisky <troy.kisky@boundarydevices.com>,
        Andrew Lunn <andrew@lunn.ch>, Eric Nelson <eric@nelint.com>,
        Philippe Reynes <tremyfr@gmail.com>,
        Johannes Berg <johannes@sipsolutions.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Chris Healy <cphealy@gmail.com>,
        Fabio Estevam <fabio.estevam@nxp.com>,
        linux-kernel <linux-kernel@vger.kernel.org>
To: Nikita Yushchenko <nikita.yoush@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480925763-20254-1-git-send-email-nikita.yoush@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 5, 2016 at 6:16 AM, Nikita Yushchenko
<nikita.yoush@cogentembedded.com> wrote:
> Commit 4dfb80d18d05 ("net: fec: cache statistics while device is down")
> introduced unconditional statistics-related actions.
>
> However, when driver is compiled with CONFIG_M5272, staticsics-related
> definitions do not exist, which results into build errors.
>
> Fix that by adding explicit handling of !defined(CONFIG_M5272) case.
>
> Fixes: 4dfb80d18d05 ("net: fec: cache statistics while device is down")
> Signed-off-by: Nikita Yushchenko <nikita.yoush@cogentembedded.com>

Looks better now:

Reviewed-by: Fabio Estevam <fabio.estevam@nxp.com>
