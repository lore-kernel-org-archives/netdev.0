From: Greg KH <greg@kroah.com>
Subject: Re: STABLE: net: reduce skb_warn_bad_offload() noise
Date: Fri, 4 Aug 2017 12:53:58 -0700
Message-ID: <20170804195358.GD3477@kroah.com>
References: <4b5d320a-a12e-b27b-cc58-332614684bf2@android.com>
 <20170728.123010.242124876818464581.davem@davemloft.net>
 <1501305772.1876.0.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, salyzyn@android.com,
        stable@vger.kernel.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1501305772.1876.0.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 28, 2017 at 10:22:52PM -0700, Eric Dumazet wrote:
> On Fri, 2017-07-28 at 12:30 -0700, David Miller wrote:
> > From: Mark Salyzyn <salyzyn@android.com>
> > Date: Fri, 28 Jul 2017 10:29:57 -0700
> > 
> > > Please backport the upstream patch to the stable trees (including
> > > 3.10.y, 3.18.y, 4.4.y and 4.9.y):
> > > 
> > > b2504a5dbef3305ef41988ad270b0e8ec289331c net: reduce
> > > skb_warn_bad_offload() noise
> > > 
> > > Impacting performance or creating unnecessary alarm, and will result
> > > in kernel panic for panic_on_warn configuration.
> > 
> > Yeah this is fine.
> 
> If you do so, also backport 6e7bc478c9a006c701c14476ec9d389a484b4864
> ("net: skb_needs_check() accepts CHECKSUM_NONE for tx")

Thanks for letting us know, I've queued this up as well.

greg k-h
