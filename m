From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [patch] net: renesas: ravb: unintialized return value
Date: Fri, 2 Dec 2016 00:13:57 +0300
Message-ID: <84f464ed-0ae3-ef5a-92a6-75d6085f32b9@cogentembedded.com>
References: <20161201205744.GB10701@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Yoshihiro Kaneko <ykaneko0929@gmail.com>,
        Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>,
        Simon Horman <horms+renesas@verge.net.au>,
        Wolfram Sang <wsa+renesas@sang-engineering.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Philippe Reynes <tremyfr@gmail.com>,
        =?UTF-8?Q?Niklas_S=c3=b6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>,
        Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>,
        Johan Hovold <johan@kernel.org>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <20161201205744.GB10701@mwanda>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

On 12/01/2016 11:57 PM, Dan Carpenter wrote:

> We want to set the other "err" variable here so that we can return it
> later.  My version of GCC misses this issue but I caught it with a
> static checker.
>
> Fixes: 9f70eb339f52 ("net: ethernet: renesas: ravb: fix fixed-link phydev leaks")

    Hm, I somehow missed this one, probably due to the horrific CC list. :-(

> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

MBR, Sergei
