From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH RFC] tun: experimental zero copy tx support
Date: Wed, 16 May 2012 08:16:55 -0700
Message-ID: <1337181415.10741.18.camel@oc3660625478.ibm.com>
References: <20120513155206.GA26847@redhat.com>
	 <1337016890.3851.20.camel@oc3660625478.ibm.com>
	 <20120514183929.GB17086@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Joe Perches <joe@perches.com>,
	Jason Wang <jasowang@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Ian.Campbell@citrix.com,
	kvm@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20120514183929.GB17086@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-05-14 at 21:39 +0300, Michael S. Tsirkin wrote:
> > Hello Mike,
> > 
> > Have you tested this patch? I think the difference between macvtap
> and
> > tap is tap forwarding the packet to bridge. The zerocopy is disabled
> in
> > this case.
> > 
> > Shirley
> 
> Testing in progress, but the patchset I pointed to enables
> zerocopy with bridge. 

Hello Mike,

You meant this patch or another patchset for enabling bridge zerocopy?

I remembered we disabled forward skb zerocopy since the user space
program might hold the buffers too long or forever.

In tap/bridge case, when the tx buffers will be released?

Thanks
Shirley

