From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH 2/2] virtio_net: remove send completion interrupts and
 avoid TX queue overrun through packet drop
Date: Fri, 18 Mar 2011 09:54:02 -0700
Message-ID: <1300467242.3441.2.camel@localhost.localdomain>
References: <1300320775.3255.34.camel@localhost.localdomain>
	 <20110317050242.GC32049@redhat.com>
	 <1300375115.3255.45.camel@localhost.localdomain>
	 <1300418927.3255.62.camel@localhost.localdomain>
	 <20110318131558.GC4221@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	netdev@vger.kernel.org, Herbert Xu <herbert@gondor.hengli.com.au>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20110318131558.GC4221@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2011-03-18 at 15:15 +0200, Michael S. Tsirkin wrote:
> Is this the local or remote throughput?
> With UDP_STREAM you are mostly interested in
> remote throughput, local one can be pretty high
> while most packets get dropped. 

This is local throughput. Remote is called recv(netserver) data. With
default wmem/rmem, there are so many recv errors. I haven't tuned the
results yet.

Thanks
Shirley

