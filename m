From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [2.6 patch] net/802/fc.c: remove fc_type_trans
Date: Tue, 15 Mar 2005 10:26:52 -0800
Message-ID: <20050315102652.2d122c2f.davem@davemloft.net>
References: <20050306205754.GO5070@stusta.de>
	<20050314214940.4947ccd9.davem@davemloft.net>
	<20050315122017.GF3189@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20050315122017.GF3189@stusta.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 15 Mar 2005 13:20:17 +0100
Adrian Bunk <bunk@stusta.de> wrote:

> On Mon, Mar 14, 2005 at 09:49:40PM -0800, David S. Miller wrote:
> > On Sun, 6 Mar 2005 21:57:54 +0100
> > Adrian Bunk <bunk@stusta.de> wrote:
> > 
> > > The only user of fc_type_trans (drivers/net/fc/iph5526.c) is BROKEN in 
> > > 2.6 and removed in -mm.
> > > 
> > > Signed-off-by: Adrian Bunk <bunk@stusta.de>
> > 
> > That driver isn't in Linus's tree any longer either.  Just delete
> > the thing altogether instead of #if 0'ing it.
> >...
> 
> Updated patch:

Applied, thanks a lot Adrian.
