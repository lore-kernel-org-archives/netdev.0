From: Jon Maloy <jon.maloy@ericsson.com>
Subject: RE: [PATCH 27/31] net/tipc: use kmemdup rather than duplicating its
 implementation
Date: Thu, 17 Sep 2015 09:58:08 +0000
Message-ID: <A2BAEFC30C8FD34388F02C9B3121859D2232ECFD@eusaamb103.ericsson.se>
References: <1438934377-4922-1-git-send-email-a.hajda@samsung.com>
 <1438934377-4922-28-git-send-email-a.hajda@samsung.com>
 <55F93F55.70505@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Andrzej Hajda <a.hajda@samsung.com>,
	Ying Xue <ying.xue@windriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55F93F55.70505@samsung.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Acked-by: Jon Maloy <jon.maloy@ericsson.com>

///jon

> -----Original Message-----
> From: Andrzej Hajda [mailto:a.hajda@samsung.com]
> Sent: Wednesday, 16 September, 2015 06:07
> To: Jon Maloy; Ying Xue
> Cc: Bartlomiej Zolnierkiewicz; Marek Szyprowski; linux-
> kernel@vger.kernel.org; David S. Miller; netdev@vger.kernel.org
> Subject: Re: [PATCH 27/31] net/tipc: use kmemdup rather than duplicating its
> implementation
> 
> Ping.
> 
> Regards
> Andrzej
> 
> On 08/07/2015 09:59 AM, Andrzej Hajda wrote:
> > The patch was generated using fixed coccinelle semantic patch
> > scripts/coccinelle/api/memdup.cocci [1].
> >
> > [1]: http://permalink.gmane.org/gmane.linux.kernel/2014320
> >
> > Signed-off-by: Andrzej Hajda <a.hajda@samsung.com>
> > ---
> >  net/tipc/server.c | 3 +--
> >  1 file changed, 1 insertion(+), 2 deletions(-)
> >
> > diff --git a/net/tipc/server.c b/net/tipc/server.c index
> > 922e04a..c187cad 100644
> > --- a/net/tipc/server.c
> > +++ b/net/tipc/server.c
> > @@ -411,13 +411,12 @@ static struct outqueue_entry
> *tipc_alloc_entry(void *data, int len)
> >  	if (!entry)
> >  		return NULL;
> >
> > -	buf = kmalloc(len, GFP_ATOMIC);
> > +	buf = kmemdup(data, len, GFP_ATOMIC);
> >  	if (!buf) {
> >  		kfree(entry);
> >  		return NULL;
> >  	}
> >
> > -	memcpy(buf, data, len);
> >  	entry->iov.iov_base = buf;
> >  	entry->iov.iov_len = len;
> >
