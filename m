From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [Lsf] [Lsf-pc] [LSF/MM TOPIC] Generic page-pool recycle facility?
Date: Tue, 12 Apr 2016 08:37:54 -0700
Message-ID: <CAKgT0Uf7qsqYXq=GfCehcEpMRn2t6TyM50h_NFvDQnOoemfsbw@mail.gmail.com>
References: <1460034425.20949.7.camel@HansenPartnership.com>
	<20160407161715.52635cac@redhat.com>
	<20160407143854.GA7685@infradead.org>
	<570678B7.7010802@sandisk.com>
	<570A9F5B.5010600@grimberg.me>
	<20160411234157.3fc9c6fe@redhat.com>
	<CAKgT0UdbO00-Pe3xdrCC2T8L=XVZasWSQQVzTTs9r521RDes+Q@mail.gmail.com>
	<20160412082838.4ce17c1a@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "lsf@lists.linux-foundation.org" <lsf@lists.linux-foundation.org>,
	James Bottomley <James.Bottomley@hansenpartnership.com>,
	Sagi Grimberg <sagi@grimberg.me>,
	Tom Herbert <tom@herbertland.com>,
	Brenden Blanco <bblanco@plumgrid.com>,
	Christoph Hellwig <hch@infradead.org>,
	linux-mm <linux-mm@kvack.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Bart Van Assche <bart.vanassche@sandisk.com>,
	"lsf-pc@lists.linux-foundation.org"
	<lsf-pc@lists.linux-foundation.org>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:35790 "EHLO
	mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965107AbcDLPhz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2016 11:37:55 -0400
Received: by mail-io0-f177.google.com with SMTP id g185so33137517ioa.2
        for <netdev@vger.kernel.org>; Tue, 12 Apr 2016 08:37:54 -0700 (PDT)
In-Reply-To: <20160412082838.4ce17c1a@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 11, 2016 at 11:28 PM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:
>
> On Mon, 11 Apr 2016 15:02:51 -0700 Alexander Duyck <alexander.duyck@gmail.com> wrote:
>
>> Have you taken a look at possibly trying to optimize the DMA pool API
>> to work with pages?  It sounds like it is supposed to do something
>> similar to what you are wanting to do.
>
> Yes, I have looked at the mm/dmapool.c API. AFAIK this is for DMA
> coherent memory (see use of dma_alloc_coherent/dma_free_coherent).
>
> What we are doing is "streaming" DMA memory, when processing the RX
> ring.
>
> (NIC are only using DMA coherent memory for the descriptors, which are
> allocated on driver init)

Yes, I know that but it shouldn't take much to extend the API to
provide the option for a streaming DMA mapping.  That was why I
thought you might want to look in this direction.

- Alex
