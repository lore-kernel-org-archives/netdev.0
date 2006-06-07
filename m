From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.17-rc5-mm3-lockdep -
Date: Wed, 7 Jun 2006 17:12:08 +1000
Message-ID: <20060607071208.GA1951@gondor.apana.org.au>
References: <200606060250.k562oCrA004583@turing-police.cc.vt.edu>
	<44852819.2080503@gmail.com> <4485798B.4030007@s5r6.in-berlin.de>
	<4485AFB9.3040005@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, Valdis.Kletnieks@vt.edu,
	Jiri Slaby <jirislaby@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mingo@redhat.com,
	linux1394-devel@lists.sourceforge.net,
	"David S. Miller" <davem@davemloft.net>, arjan@infradead.org
Return-path: <linux1394-devel-bounces@lists.sourceforge.net>
To: Stefan Richter <stefanr@s5r6.in-berlin.de>
Content-Disposition: inline
In-Reply-To: <4485AFB9.3040005@s5r6.in-berlin.de>
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

On Tue, Jun 06, 2006 at 04:39:21PM +0000, Stefan Richter wrote:
> 
> BTW, the locking in -mm's net/unix/af_unix.c::unix_stream_connect() 
> differs a bit from stock unix_stream_connect(). I see spin_lock_bh() in 
> 2.6.17-rc5-mm3 where 2.6.17-rc5 has spin_lock().

Hi Ingo:

Looks like this change was introduced by the validator patch.  Any idea
why this was done? AF_UNIX is a user-space-driven socket so there shouldn't
be any need for BH to be disabled there.

Even if it does this patch should go through the normal channels rather
than the lock validator.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
