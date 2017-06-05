From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH] net-next: stmmac: dwmac-sun8i: ensure the
 EPHY is properly reseted
Date: Mon, 5 Jun 2017 14:44:19 +0200
Message-ID: <20170605124419.GF28734@lunn.ch>
References: <20170604175323.62124-1-icenowy@aosc.io>
 <20170605111019.GA29657@Red>
Reply-To: andrew-g2DYL2Zd6BY@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Icenowy Zheng <icenowy-h8G6r0blFSE@public.gmane.org>,
	"David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
To: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-sunxi+bncBDJNHL5JSEOBBMVE2XEQKGQEUIKE2LY-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Content-Disposition: inline
In-Reply-To: <20170605111019.GA29657@Red>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

On Mon, Jun 05, 2017 at 01:10:19PM +0200, Corentin Labbe wrote:
> On Mon, Jun 05, 2017 at 01:53:23AM +0800, Icenowy Zheng wrote:
> > The EPHY may be already enabled by bootloaders which have Ethernet
> > capability (e.g. current U-Boot). Thus it should be reseted properly
> > before doing the enabling sequence in the dwmac-sun8i driver, otherwise
> > the EMAC reset process may fail if no cable is plugged, and then fail
> > the dwmac-sun8i probing.
> > 
> > Tested on Orange Pi PC, One and Zero. All the boards fail to have
> > dwmac-sun8i probed with "EMAC reset timeout" without cable plugged
> > before, and with this fix they're now all able to successfully probe the
> > EMAC without cable plugged and then use the connection after a cable is
> > hot-plugged in.
> > 
> > Fixes: 9f93ac8d408 ("net-next: stmmac: Add dwmac-sun8i")
> > Signed-off-by: Icenowy Zheng <icenowy-h8G6r0blFSE@public.gmane.org>
> 
> Thanks for the fix.
> Tested-by: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> 
> Since I am the writter of the file, does I have the right to:
> Acked-by: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> or
> Reviewed-by: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Documentation/process/submitting-patches.rst says:

If a person was not directly involved in the preparation or handling of a
patch but wishes to signify and record their approval of it then they can
ask to have an Acked-by: line added to the patch's changelog.

Acked-by: is not as formal as Signed-off-by:.  It is a record that the acker
has at least reviewed the patch and has indicated acceptance.

Nothing limits who can give an Acked-by, you just need to of done the
necessary work.

Reviewed-by: is similar.

So feel free to have either.

   Andrew
