From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 1/1] Defer skb allocation for both mergeable buffers
	and big packets in virtio_net
Date: Wed, 25 Nov 2009 13:40:29 +0200
Message-ID: <20091125114029.GA9333@redhat.com>
References: <1258697745.7416.20.camel@localhost.localdomain> <200911251042.06368.rusty@rustcorp.com.au> <20091125091530.GA6357@redhat.com> <200911252050.21907.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Shirley Ma <mashirle@us.ibm.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Avi Kivity <avi@redhat.com>, netdev@vger.kernel.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org,
	Hollis Blanchard <hollisb@us.ibm.com>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758741AbZKYLnS@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200911252050.21907.rusty@rustcorp.com.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 25, 2009 at 08:50:21PM +1030, Rusty Russell wrote:
> On Wed, 25 Nov 2009 07:45:30 pm Michael S. Tsirkin wrote:
> > Hmm, is it really worth it to save a header copy if it's linear?  We are
> > going to access it anyway, and it fits into one cacheline nicely.  On
> > the other hand we have more code making life harder for compiler and
> > processor.
> 
> Not sure: I think there would be many places where it would be useful.
> 
> We do a similar thing in the kernel to inspect non-linear packets, and
> it's served us well.

You mean this gives measureable speedup? Okay ...

> Cheers,
> Rusty.
