From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] TX_RING and packet mmap
Date: Wed, 6 May 2009 09:38:05 +0000
Message-ID: <20090506093805.GA6071@ff.dom.local>
References: <1241559489.5921.13.camel@bender> <20090506070710.GB4571@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>,
	Christoph Lameter <cl@linux.com>,
	Evgeniy Polyakov <zbr@ioremap.net>
To: Johann Baudy <johann.baudy@gnu-log.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.171]:50423 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757858AbZEFJiO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 05:38:14 -0400
Received: by wf-out-1314.google.com with SMTP id 26so4376723wfd.4
        for <netdev@vger.kernel.org>; Wed, 06 May 2009 02:38:15 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090506070710.GB4571@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 06, 2009 at 07:07:10AM +0000, Jarek Poplawski wrote:
> On 05-05-2009 23:38, Johann Baudy wrote:
> > From: Johann Baudy <johann.baudy@gnu-log.net>
> > 
> > New packet socket feature that makes packet socket more efficient for transmission.
> > - It reduces number of system call through a PACKET_TX_RING mechanism, based on PACKET_RX_RING (Circular buffer allocated in kernel space which is mmapped from user space).
> > - It minimizes CPU copy using fragmented SKB (almost zero copy).
> > 
> > Signed-off-by: Johann Baudy <johann.baudy@gnu-log.net>
> > 
> > --
> > Update:
> 
> FYI, this patch is malformed by your mta.

After some discussion on private I admit I might be wrong about it
(since I didn't get this message directly from netdev@), then sorry
for disturbing.

Jarek P.
