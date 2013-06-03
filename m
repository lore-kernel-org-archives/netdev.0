From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [Xen-devel] xen-netback stable backports request (regression
 fixes)
Date: Mon, 3 Jun 2013 14:50:54 +0100
Message-ID: <1370267454.24512.7.camel@zakaz.uk.xensource.com>
References: <1369734465.3469.52.camel@zakaz.uk.xensource.com>
	 <CAJ75kXbyqa=HJD7x9OoGTh99YoiUJz8ioEdMwh5Ryko5daev-g@mail.gmail.com>
	 <CAJ75kXZcdAc5x+p8789rKnS2mUJcd4wAS2NwBfKi7yPqYN1T-w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>,
	Luis Henriques <luis.henriques@canonical.com>,
	<netdev@vger.kernel.org>, <stable@vger.kernel.org>,
	xen-devel <xen-devel@lists.xen.org>,
	"David S. Miller" <davem@davemloft.net>
To: William Dauchy <wdauchy@gmail.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <CAJ75kXZcdAc5x+p8789rKnS2mUJcd4wAS2NwBfKi7yPqYN1T-w@mail.gmail.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-05-31 at 15:45 +0200, William Dauchy wrote:
> On Fri, May 31, 2013 at 3:20 PM, William Dauchy <wdauchy@gmail.com> wrote:
> > I applied the patches on a 3.4.x kernel.
> > for netback I had to include:
> > 9eaee8b xen-netback: fix sparse warning
> > which I guess is ok to include in 3.4
> >
> > for netfront, as Luis said, I also add to include:
> > f36c374 xen/netfront: handle compound page fragments on transmit
> > which is not a simple patch.
> 
> at the end, it is not really clever to include f36c374 in 3.4.x since
> 6a8ed46 xen: netback: handle compound page fragments on transmit.
> is not present in netback for 3.4.x

Right, that would be my thinking too, although the patch should be
"harmless" (i.e. it should work fine with non-compound frags) its not
totally trivial so unless the backport of f36c374 is made especially
hard without it its likely not worth the risk.

> at least the netback part is ok for me.

Thanks,
Ian.
