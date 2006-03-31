From: Mark Nipper <nipsy@bitgnome.net>
Subject: Re: [e1000 debug] KERNEL: assertion (!sk_forward_alloc) failed...
Date: Fri, 31 Mar 2006 06:10:08 -0600
Message-ID: <20060331121007.GA2146@king.bitgnome.net>
References: <442BAC99.2090404@kernelpanic.ru> <20060330101218.GA2905@gondor.apana.org.au> <442BDD25.1060000@kernelpanic.ru> <20060331.011245.26474207.davem@davemloft.net> <442D0186.8090705@kernelpanic.ru> <20060331103956.GA12181@gondor.apana.org.au> <442D1B67.8000804@kernelpanic.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, jesse.brandeburg@intel.com,
	nipsy@bitgnome.net, jrlundgren@gmail.com, cat@zip.com.au,
	djani22@dynamicweb.hu, yoseph.basri@gmail.com, mykleb@no.ibm.com,
	olel@ans.pl, michal@feix.cz, chris@scorpion.nl,
	netdev@vger.kernel.org, jesse.brandeburg@gmail.com,
	E1000-devel@lists.sourceforge.net, Andi Kleen <ak@suse.de>,
	Jeff Garzik <jgarzik@pobox.com>
Return-path: <e1000-devel-admin@lists.sourceforge.net>
To: "Boris B. Zhmurov" <bb@kernelpanic.ru>
Content-Disposition: inline
In-Reply-To: <442D1B67.8000804@kernelpanic.ru>
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

On 31 Mar 2006, Boris B. Zhmurov wrote:
> David, Herbert - FYI. One of my colleague confirmed, that idea "bug 
> reproducible only if there is more then one e1000 adapter onboard" is 
> true. He has a 3 servers with double intel pro 1000 adapters, and that 
> bug occurs. Also, he has 4 servers with double intel pro 1000 adapters 
> onboard, but _only one_ of them is up. And there is no such messages in 
> dmesg at all! Inetresting...

        This unfortunately is not the case.  I have two e1000
interfaces but only eth1 is up and in use.  And I still had
assertions.  Hopefully the two already discovered problems will
fix things up for everyone though.

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
Generalizations are usually flawed by exceptions.
 -- seen at http://wunderland.com/
----end random quote of the moment----


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
