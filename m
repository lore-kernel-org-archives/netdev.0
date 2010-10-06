From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [v2 RFC PATCH 0/4] Implement multiqueue virtio-net
Date: Wed, 6 Oct 2010 22:32:58 +0530
Message-ID: <OF100CCF89.C4918777-ON652577B4.005D3627-652577B4.005D6422@in.ibm.com>
References: <cover.1286372004.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: anthony@codemonkey.ws, arnd@arndb.de, avi@redhat.com,
	davem@davemloft.net, kvm@vger.kernel.org, netdev@vger.kernel.org,
	rusty@rustcorp.com.au
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <cover.1286372004.git.mst@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Michael S. Tsirkin" <mst@redhat.com> wrote on 10/06/2010 07:04:31 PM:

> "Michael S. Tsirkin" <mst@redhat.com>
> 10/06/2010 07:04 PM
>
> To
>
> Krishna Kumar2/India/IBM@IBMIN
>
> cc
>
> rusty@rustcorp.com.au, davem@davemloft.net, kvm@vger.kernel.org,
> arnd@arndb.de, netdev@vger.kernel.org, avi@redhat.com,
anthony@codemonkey.ws
>
> Subject
>
> Re: [v2 RFC PATCH 0/4] Implement multiqueue virtio-net
>
> On Fri, Sep 17, 2010 at 03:33:07PM +0530, Krishna Kumar wrote:
> > For 1 TCP netperf, I ran 7 iterations and summed it. Explanation
> > for degradation for 1 stream case:
>
> I thought about possible RX/TX contention reasons, and I realized that
> we get/put the mm counter all the time.  So I write the following: I
> haven't seen any performance gain from this in a single queue case, but
> maybe this will help multiqueue?

Great! I am on vacation tomorrow, but will test with this patch
tomorrow night.

Thanks,

- KK

