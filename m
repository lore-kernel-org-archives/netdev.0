From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [2.6 patch] net/802/fc.c: #if 0 fc_type_trans
Date: Mon, 14 Mar 2005 21:49:40 -0800
Message-ID: <20050314214940.4947ccd9.davem@davemloft.net>
References: <20050306205754.GO5070@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20050306205754.GO5070@stusta.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 6 Mar 2005 21:57:54 +0100
Adrian Bunk <bunk@stusta.de> wrote:

> The only user of fc_type_trans (drivers/net/fc/iph5526.c) is BROKEN in 
> 2.6 and removed in -mm.
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

That driver isn't in Linus's tree any longer either.  Just delete
the thing altogether instead of #if 0'ing it.

Thanks.
