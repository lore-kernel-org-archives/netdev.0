From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 1/1] Defer skb allocation for both mergeable buffers and big packets in virtio_net
Date: Wed, 25 Nov 2009 20:50:21 +1030
Message-ID: <200911252050.21907.rusty@rustcorp.com.au>
References: <1258697745.7416.20.camel@localhost.localdomain> <200911251042.06368.rusty@rustcorp.com.au> <20091125091530.GA6357@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Shirley Ma <mashirle@us.ibm.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Avi Kivity <avi@redhat.com>, netdev@vger.kernel.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org,
	Hollis Blanchard <hollisb@us.ibm.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758584AbZKYKUU@vger.kernel.org>
In-Reply-To: <20091125091530.GA6357@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 25 Nov 2009 07:45:30 pm Michael S. Tsirkin wrote:
> Hmm, is it really worth it to save a header copy if it's linear?  We are
> going to access it anyway, and it fits into one cacheline nicely.  On
> the other hand we have more code making life harder for compiler and
> processor.

Not sure: I think there would be many places where it would be useful.

We do a similar thing in the kernel to inspect non-linear packets, and
it's served us well.

Cheers,
Rusty.
