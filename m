From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] TX_RING and packet mmap
Date: Wed, 6 May 2009 07:07:10 +0000
Message-ID: <20090506070710.GB4571@ff.dom.local>
References: <1241559489.5921.13.camel@bender>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>,
	Christoph Lameter <cl@linux.com>,
	Evgeniy Polyakov <zbr@ioremap.net>
To: Johann Baudy <johann.baudy@gnu-log.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.26]:19210 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751014AbZEFHHS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 03:07:18 -0400
Received: by qw-out-2122.google.com with SMTP id 5so4080222qwd.37
        for <netdev@vger.kernel.org>; Wed, 06 May 2009 00:07:18 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1241559489.5921.13.camel@bender>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05-05-2009 23:38, Johann Baudy wrote:
> From: Johann Baudy <johann.baudy@gnu-log.net>
> 
> New packet socket feature that makes packet socket more efficient for transmission.
> - It reduces number of system call through a PACKET_TX_RING mechanism, based on PACKET_RX_RING (Circular buffer allocated in kernel space which is mmapped from user space).
> - It minimizes CPU copy using fragmented SKB (almost zero copy).
> 
> Signed-off-by: Johann Baudy <johann.baudy@gnu-log.net>
> 
> --
> Update:

FYI, this patch is malformed by your mta.

Jarek P.
