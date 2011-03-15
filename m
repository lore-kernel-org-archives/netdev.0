From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Subject: Re: [GIT/PATCH v5] xen network backend driver
Date: Tue, 15 Mar 2011 10:06:31 +0000
Message-ID: <1300183591.17339.2240.camel@zakaz.uk.xensource.com>
References: <1300112879.17339.2162.camel@zakaz.uk.xensource.com>
	<1300128035.2584.6.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jeremy Fitzhardinge <jeremy@goop.org>,
	xen-devel <xen-devel@lists.xensource.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirqus@gmail.com>,
	Francois Romieu <romieu@fr.zoreil.com>, Stephen,
	Hemminger <shemminger@vyatta.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <xen-devel-bounces@lists.xensource.com>
In-Reply-To: <1300128035.2584.6.camel@bwh-desktop>
List-Unsubscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

On Mon, 2011-03-14 at 18:40 +0000, Ben Hutchings wrote:
> On Mon, 2011-03-14 at 14:27 +0000, Ian Campbell wrote:
> > The following patch is the fifth iteration of the Xen network backend
> > driver for upstream Linux.
> > 
> > This driver ("netback") is the host side counterpart to the frontend
> > driver in drivers/net/xen-netfront.c. The PV protocol is also
> > implemented by frontend drivers in other OSes too, such as the BSDs and
> > even Windows.
> > 
> > Changes since the fourth posting, due to review from Stephen Hemminger:
> >       * Treat dev->features as u32 (it effectively is already and
> >         becomes literally so in net-next -- there's no harm in netback
> >         switching earlier)
> >       * Use stats from struct netdevice instead of a local copy.
> [...]
> 
> All looks good (or good enough) to me.  I would add Reviewed-by, but
> this isn't a single patch.

Since David asked me to post as a single patch I've added your review by
to that. I hope that's ok.

Thanks,
Ian.
