From: William Dauchy <wdauchy@gmail.com>
Subject: Re: [Xen-devel] xen-netback stable backports request (regression fixes)
Date: Fri, 31 May 2013 15:45:25 +0200
Message-ID: <CAJ75kXZcdAc5x+p8789rKnS2mUJcd4wAS2NwBfKi7yPqYN1T-w@mail.gmail.com>
References: <1369734465.3469.52.camel@zakaz.uk.xensource.com> <CAJ75kXbyqa=HJD7x9OoGTh99YoiUJz8ioEdMwh5Ryko5daev-g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: stable@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org, Wei Liu <wei.liu2@citrix.com>,
	xen-devel <xen-devel@lists.xen.org>,
	Luis Henriques <luis.henriques@canonical.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <CAJ75kXbyqa=HJD7x9OoGTh99YoiUJz8ioEdMwh5Ryko5daev-g@mail.gmail.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 31, 2013 at 3:20 PM, William Dauchy <wdauchy@gmail.com> wrote:
> I applied the patches on a 3.4.x kernel.
> for netback I had to include:
> 9eaee8b xen-netback: fix sparse warning
> which I guess is ok to include in 3.4
>
> for netfront, as Luis said, I also add to include:
> f36c374 xen/netfront: handle compound page fragments on transmit
> which is not a simple patch.

at the end, it is not really clever to include f36c374 in 3.4.x since
6a8ed46 xen: netback: handle compound page fragments on transmit.
is not present in netback for 3.4.x

at least the netback part is ok for me.

--
William
