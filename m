From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH RFC] tun: experimental zero copy tx support
Date: Wed, 16 May 2012 19:51:32 +0300
Message-ID: <20120516165131.GB10769@redhat.com>
References: <20120513155206.GA26847@redhat.com>
 <1337016890.3851.20.camel@oc3660625478.ibm.com>
 <20120514183929.GB17086@redhat.com>
 <1337181415.10741.18.camel@oc3660625478.ibm.com>
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
In-Reply-To: <1337181415.10741.18.camel@oc3660625478.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 16, 2012 at 08:16:55AM -0700, Shirley Ma wrote:
> On Mon, 2012-05-14 at 21:39 +0300, Michael S. Tsirkin wrote:
> > > Hello Mike,
> > > 
> > > Have you tested this patch? I think the difference between macvtap
> > and
> > > tap is tap forwarding the packet to bridge. The zerocopy is disabled
> > in
> > > this case.
> > > 
> > > Shirley
> > 
> > Testing in progress, but the patchset I pointed to enables
> > zerocopy with bridge. 
> 
> Hello Mike,
> 
> You meant this patch or another patchset for enabling bridge zerocopy?
> 
> I remembered we disabled forward skb zerocopy since the user space
> program might hold the buffers too long or forever.
> 
> In tap/bridge case, when the tx buffers will be released?
> 
> Thanks
> Shirley

It still fails some tests for me but maybe I'll post the whole
patchset so you can see how it works.
