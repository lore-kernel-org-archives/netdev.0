From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH RFC] tun: experimental zero copy tx support
Date: Mon, 14 May 2012 20:04:13 +0300
Message-ID: <20120514170412.GA17086@redhat.com>
References: <20120513155206.GA26847@redhat.com>
 <20120514095446.3ce307d2@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Joe Perches <joe@perches.com>,
	Jason Wang <jasowang@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Ian.Campbell@citrix.com,
	kvm@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120514095446.3ce307d2@nehalam.linuxnetplumber.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 14, 2012 at 09:54:46AM -0700, Stephen Hemminger wrote:
> On Sun, 13 May 2012 18:52:06 +0300
> "Michael S. Tsirkin" <mst@redhat.com> wrote:
> 
> > +		/* Userspace may produce vectors with count greater than
> > +		 * MAX_SKB_FRAGS, so we need to linearize parts of the skb
> > +		 * to let the rest of data to be fit in the frags.
> > +		 */
> Rather than complex partial code, just go through slow path for
> requests with too many frags (or for really small requests).
> Creating mixed skb's seems too easy to get wrong.

I don't object in principle but macvtap has same code
so seems better to stay consistent.

-- 
MST
