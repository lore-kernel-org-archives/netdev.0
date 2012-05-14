From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH RFC] tun: experimental zero copy tx support
Date: Mon, 14 May 2012 21:39:30 +0300
Message-ID: <20120514183929.GB17086@redhat.com>
References: <20120513155206.GA26847@redhat.com>
 <1337016890.3851.20.camel@oc3660625478.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Joe Perches <joe@perches.com>,
	Jason Wang <jasowang@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Ian.Campbell@citrix.com,
	kvm@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1337016890.3851.20.camel@oc3660625478.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 14, 2012 at 10:34:50AM -0700, Shirley Ma wrote:
> On Sun, 2012-05-13 at 18:52 +0300, Michael S. Tsirkin wrote:
> > Let vhost-net utilize zero copy tx when the experimental
> > zero copy mode is enabled and when used with tun.  This works on
> > top of the patchset 'copy aside frags with destructors' that I posted
> > previously. This is not using tcp so doesn't have the
> > issue with early skb cloning noticed by Ian.
> > 
> > For those that wish to test this with kvm, I intend to post a patchset
> > +
> > git tree with just the necessary bits from the destructor patch
> > a bit later.
> > 
> > Signed-off-by: Michael S. Tsirkin <mst@redhat.com> 
> 
> Hello Mike,
> 
> Have you tested this patch? I think the difference between macvtap and
> tap is tap forwarding the packet to bridge. The zerocopy is disabled in
> this case.
> 
> Shirley

Testing in progress, but the patchset I pointed to enables
zerocopy with bridge.
