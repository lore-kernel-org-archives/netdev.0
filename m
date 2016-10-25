From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH] [net-next] net: ip, diag: include net/inet_sock.h
Date: Tue, 25 Oct 2016 19:06:02 +0300
Message-ID: <20161025160602.GZ1847@uranus.lan>
References: <20161025155339.9892-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161025155339.9892-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 25, 2016 at 05:53:22PM +0200, Arnd Bergmann wrote:
> The newly added raw_diag.c fails to build in some configurations
> unless we include this header:
> 
> In file included from net/ipv4/raw_diag.c:6:0:
> include/net/raw.h:71:21: error: field 'inet' has incomplete type
> net/ipv4/raw_diag.c: In function 'raw_diag_dump':
> net/ipv4/raw_diag.c:166:29: error: implicit declaration of function 'inet_sk'
> 
> Fixes: 432490f9d455 ("net: ip, diag -- Add diag interface for raw sockets")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Thank you! And sorry for this, it didn't trigger on my testing.
