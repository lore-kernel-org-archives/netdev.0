From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [Lsf] [Lsf-pc] [LSF/MM TOPIC] Generic page-pool recycle
 facility?
Date: Tue, 12 Apr 2016 08:28:38 +0200
Message-ID: <20160412082838.4ce17c1a@redhat.com>
References: <1460034425.20949.7.camel@HansenPartnership.com>
	<20160407161715.52635cac@redhat.com>
	<20160407143854.GA7685@infradead.org>
	<570678B7.7010802@sandisk.com>
	<570A9F5B.5010600@grimberg.me>
	<20160411234157.3fc9c6fe@redhat.com>
	<CAKgT0UdbO00-Pe3xdrCC2T8L=XVZasWSQQVzTTs9r521RDes+Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "lsf@lists.linux-foundation.org" <lsf@lists.linux-foundation.org>,
        James
 Bottomley <James.Bottomley@hansenpartnership.com>,
        Sagi Grimberg
 <sagi@grimberg.me>, Tom Herbert <tom@herbertland.com>,
        Brenden Blanco
 <bblanco@plumgrid.com>,
        Christoph Hellwig <hch@infradead.org>, linux-mm
 <linux-mm@kvack.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Bart Van Assche <bart.vanassche@sandisk.com>,
        "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>, brouer@redhat.com
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <CAKgT0UdbO00-Pe3xdrCC2T8L=XVZasWSQQVzTTs9r521RDes+Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org


On Mon, 11 Apr 2016 15:02:51 -0700 Alexander Duyck <alexander.duyck@gmail.com> wrote:

> Have you taken a look at possibly trying to optimize the DMA pool API
> to work with pages?  It sounds like it is supposed to do something
> similar to what you are wanting to do.

Yes, I have looked at the mm/dmapool.c API. AFAIK this is for DMA
coherent memory (see use of dma_alloc_coherent/dma_free_coherent). 

What we are doing is "streaming" DMA memory, when processing the RX
ring.

(NIC are only using DMA coherent memory for the descriptors, which are
allocated on driver init)
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
