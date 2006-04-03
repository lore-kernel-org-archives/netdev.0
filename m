From: Mark Nipper <nipsy@bitgnome.net>
Subject: Re: [e1000 debug] KERNEL: assertion (!sk_forward_alloc) failed...
Date: Mon, 3 Apr 2006 16:01:23 -0500
Message-ID: <20060403210123.GA27698@king.bitgnome.net>
References: <442BAC99.2090404@kernelpanic.ru> <20060330101218.GA2905@gondor.apana.org.au> <442BDD25.1060000@kernelpanic.ru> <20060331.011245.26474207.davem@davemloft.net> <442D0186.8090705@kernelpanic.ru> <20060331103956.GA12181@gondor.apana.org.au> <442D1B67.8000804@kernelpanic.ru> <20060331121007.GA2146@king.bitgnome.net> <442D1F26.8050601@kernelpanic.ru> <20060331123514.GA13500@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Boris B. Zhmurov" <bb@kernelpanic.ru>,
	Mark Nipper <nipsy@bitgnome.net>,
	"David S. Miller" <davem@davemloft.net>, jesse.brandeburg@intel.com,
	jrlundgren@gmail.com, cat@zip.com.au, djani22@dynamicweb.hu,
	yoseph.basri@gmail.com, mykleb@no.ibm.com, olel@ans.pl,
	michal@feix.cz, chris@scorpion.nl, netdev@vger.kernel.org,
	jesse.brandeburg@gmail.com, E1000-devel@lists.sourceforge.net,
	Andi Kleen <ak@suse.de>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <e1000-devel-admin@lists.sourceforge.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20060331123514.GA13500@gondor.apana.org.au>
Sender: e1000-devel-admin@lists.sourceforge.net
Errors-To: e1000-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=e1000-devel>
List-Id: netdev.vger.kernel.org

On 31 Mar 2006, Herbert Xu wrote:
> If it still fails, here is a debugging patch which should tell us
> whether we need to look elsewhere.

        After three days and some hours, I finally saw another
event:
---
Apr  3 13:40:53 king kernel: KERNEL: assertion (!sk->sk_forward_alloc) failed at net/core/stream.c (283)
Apr  3 13:40:53 king kernel: KERNEL: assertion (!sk->sk_forward_alloc) failed at net/ipv4/af_inet.c (150)
---

but as with the other person who reported recently, I also did
not receive the extra debugging output from Herbert's latest
patch.

        Anyway, this happened with 2.6.16.1 and Herbert's three
patches.  Let me know if you want me to try anything different.

        I guess all of this will just go away with the latest
driver version since those of us running at 100Mbps will no
longer have TSO enabled?

-- 
Mark Nipper                                                e-contacts:
832 Tanglewood Drive                                nipsy@bitgnome.net
Bryan, Texas 77802-4013                     http://nipsy.bitgnome.net/
(979)575-3193                      AIM/Yahoo: texasnipsy ICQ: 66971617

-----BEGIN GEEK CODE BLOCK-----
Version: 3.1
GG/IT d- s++:+ a- C++$ UBL++++$ P--->+++ L+++$ !E---
W++(--) N+ o K++ w(---) O++ M V(--) PS+++(+) PE(--)
Y+ PGP t+ 5 X R tv b+++@ DI+(++) D+ G e h r++ y+(**)
------END GEEK CODE BLOCK------

---begin random quote of the moment---
He hoped and prayed that there wasn't an afterlife. Then he
realized there was a contradiction involved here and merely
hoped that there wasn't an afterlife.
 -- Douglas Adams
----end random quote of the moment----


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
