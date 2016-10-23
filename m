From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: do not increment mac header when it's unset
Date: Sun, 23 Oct 2016 17:40:03 -0400 (EDT)
Message-ID: <20161023.174003.1567709653137752244.davem@davemloft.net>
References: <CAHmME9q5yDae6qXecKK-Cdw-91geRnvzYocg=ypFucH+9LVt_g@mail.gmail.com>
        <20161021092825.28085-1-Jason@zx2c4.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, pageexec@gmail.com,
        re.emese@gmail.com
To: Jason@zx2c4.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161021092825.28085-1-Jason@zx2c4.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Date: Fri, 21 Oct 2016 18:28:25 +0900

> Otherwise we'll overflow the integer. This occurs when layer 3 tunneled
> packets are handed off to the IPv6 layer.
> 
> Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>

Applied, thanks.

Have fun playing with WireGuard.
