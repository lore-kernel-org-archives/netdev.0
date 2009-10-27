From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: performance regression in virtio-net in 2.6.32-rc4
Date: Wed, 28 Oct 2009 10:04:46 +1030
Message-ID: <200910281004.46800.rusty@rustcorp.com.au>
References: <20091026184835.GB26473@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: virtualization@lists.linux-foundation.org, kvm@vger.kernel.org,
	netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20091026184835.GB26473@redhat.com>
Content-Disposition: inline
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 27 Oct 2009 05:18:35 am Michael S. Tsirkin wrote:
> Hi!
> I noticed a performance regression in virtio net: going from
> 2.6.31 to 2.6.32-rc4 I see this, for guest to host communication:
...
> Size   Size    Size     Time     Throughput
> bytes  bytes   bytes    secs.    10^6bits/sec
> 
>  87380  16384  16384    10.20    7806.48
...
>  87380  16384  16384    10.00    6814.60

Hmm, needs a bisect I'd say.

Thanks,
Rusty.
