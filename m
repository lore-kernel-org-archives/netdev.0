From: David Miller <davem@davemloft.net>
Subject: Re: [patch] undo AF_UNIX _bh locking changes and split lock-type
	instead
Date: Mon, 12 Jun 2006 00:18:29 -0700 (PDT)
Message-ID: <20060612.001829.49243997.davem@davemloft.net>
References: <20060612064122.GA1101@gondor.apana.org.au>
	<20060612065701.GA24213@elte.hu>
	<20060612070356.GA1273@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, Valdis.Kletnieks@vt.edu, jirislaby@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	stefanr@s5r6.in-berlin.de, mingo@elte.hu,
	linux1394-devel@lists.sourceforge.net, mingo@redhat.com,
	arjan@infradead.org
Return-path: <linux1394-devel-bounces@lists.sourceforge.net>
To: herbert@gondor.apana.org.au
In-Reply-To: <20060612070356.GA1273@gondor.apana.org.au>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=linux1394-devel>
List-Post: <mailto:linux1394-devel@lists.sourceforge.net>
List-Help: <mailto:linux1394-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: linux1394-devel-bounces@lists.sourceforge.net
Errors-To: linux1394-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 12 Jun 2006 17:03:56 +1000

> On Mon, Jun 12, 2006 at 08:57:01AM +0200, Ingo Molnar wrote:
> >
> > regarding your point wrt. path of integration - it is pretty much the 
> > only practical way to do this centrally as part of the lock validator 
> > patches, but to collect ACKs from subsystem maintainers in the process. 
> > So if you like it i'd like to have your ACK but this patch depends on 
> > the other lock validator patches (and only makes sense together with 
> > them), so they should temporarily stay in the lock validator queue. 
> > Hopefully this wont be a state that lasts too long and once the 
> > validator is upstream, all patches of course go via the subsystem 
> > submission rules.
> 
> Obviously as long as Dave is happy with it then it's fine.  However,
> it's probably a good idea to cc netdev for relevant patches so that
> they get a wider review.  If you've already sent this one there then
> I apologise for missing it :)

Yes, this is fine with me.
