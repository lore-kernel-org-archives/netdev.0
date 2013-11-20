From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net] virtio-net: fix page refcnt leaking when fail to
	allocate frag skb
Date: Wed, 20 Nov 2013 19:03:33 +0200
Message-ID: <20131120170333.GA21972@redhat.com>
References: <1384848307-7217-1-git-send-email-jasowang@redhat.com>
	<1384869828.8604.97.camel@edumazet-glaptop2.roam.corp.google.com>
	<20131119204909.GA15004@redhat.com>
	<1384896996.8604.120.camel@edumazet-glaptop2.roam.corp.google.com>
	<20131119215312.GE15004@redhat.com>
	<1384898411.8604.127.camel@edumazet-glaptop2.roam.corp.google.com>
	<20131120085835.GB19341@redhat.com>
	<1384960593.8604.147.camel@edumazet-glaptop2.roam.corp.google.com>
	<20131120160625.GA21188@redhat.com>
	<1384964061.8604.151.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Michael Dalton <mwdalton@google.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org,
	Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1384964061.8604.151.camel@edumazet-glaptop2.roam.corp.google.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 20, 2013 at 08:14:21AM -0800, Eric Dumazet wrote:
> On Wed, 2013-11-20 at 18:06 +0200, Michael S. Tsirkin wrote:
> 
> > Hmm some kind of disconnect here.
> > I got you rmanagement about bufferbloat.
> > 
> > What I am saying is that maybe we should drop packets more
> > aggressively: when we drop one packet of a flow, why not
> > drop everything that's queued and is for the same flow?
> 
> I really hope your TCP flows use SACK ;)
> 
> Please read the rfc 2018 introduction for details.
> 
> If a packet is dropped, it doesn't mean following packets _have_ to be
> dropped.


Got it, thanks.
