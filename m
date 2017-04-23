From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net] ravb: Double free on error in ravb_start_xmit()
Date: Sun, 23 Apr 2017 21:16:37 +0300
Message-ID: <7e22f555-eac0-d0cb-85a2-6f2337d32bcb@cogentembedded.com>
References: <20170422104656.jjnooh3or4x3lbw3@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>,
        Simon Horman <horms+renesas@verge.net.au>,
        Yoshihiro Kaneko <ykaneko0929@gmail.com>,
        Masaru Nagai <masaru.nagai.vx@renesas.com>,
        Geert Uytterhoeven <geert+renesas@glider.be>,
        =?UTF-8?Q?Niklas_S=c3=b6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>,
        Philippe Reynes <tremyfr@gmail.com>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <20170422104656.jjnooh3or4x3lbw3@mwanda>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

On 04/22/2017 01:46 PM, Dan Carpenter wrote:

> If skb_put_padto() fails then it frees the skb.  I shifted that code
> up a bit to make my error handling a little simpler.
>
> Fixes: a0d2f20650e8 ("Renesas Ethernet AVB PTP clock driver")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

MBR, Sergei
