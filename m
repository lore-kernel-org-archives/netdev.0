From: David Miller <davem@davemloft.net>
Subject: Re: [patch] undo AF_UNIX _bh locking changes and split lock-type
	instead
Date: Mon, 12 Jun 2006 13:08:19 -0700 (PDT)
Message-ID: <20060612.130819.56815772.davem@davemloft.net>
References: <20060612064122.GA1101@gondor.apana.org.au>
	<20060612065701.GA24213@elte.hu> <20060612084936.GA29516@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, Valdis.Kletnieks@vt.edu,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stefanr@s5r6.in-berlin.de,
	jirislaby@gmail.com, linux1394-devel@lists.sourceforge.net,
	mingo@redhat.com, arjan@infradead.org
Return-path: <linux1394-devel-bounces@lists.sourceforge.net>
To: mingo@elte.hu
In-Reply-To: <20060612084936.GA29516@elte.hu>
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

From: Ingo Molnar <mingo@elte.hu>
Date: Mon, 12 Jun 2006 10:49:36 +0200

> Subject: undo AF_UNIX _bh locking changes and split lock-type
> From: Ingo Molnar <mingo@elte.hu>
> 
> this cleans up lock-validator-special-locking-af_unix.patch: instead
> of adding _bh locking to AF_UNIX, this patch splits their
> sk_receive_queue.lock type from the other networking skb-queue locks.
> 
> Signed-off-by: Ingo Molnar <mingo@elte.hu>

Signed-off-by: David S. Miller <davem@davemloft.net>
