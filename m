From: "Boris B. Zhmurov" <bb@kernelpanic.ru>
Subject: Re: [e1000 debug] KERNEL: assertion (!sk_forward_alloc) failed...
Date: Fri, 31 Mar 2006 19:19:09 +0400
Message-ID: <442D486D.909@kernelpanic.ru>
References: <442BAC99.2090404@kernelpanic.ru> <20060330101218.GA2905@gondor.apana.org.au> <442BDD25.1060000@kernelpanic.ru> <20060331.011245.26474207.davem@davemloft.net> <442D0186.8090705@kernelpanic.ru> <20060331103956.GA12181@gondor.apana.org.au> <442D1B67.8000804@kernelpanic.ru> <20060331121007.GA2146@king.bitgnome.net> <442D1F26.8050601@kernelpanic.ru> <442D24AA.8080609@kernelpanic.ru> <045601c654c4$c3dece80$3d64880a@speedy> <442D2EF6.1040703@kernelpanic.ru> <442D45EA.9010309@kernelpanic.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Christiaan den Besten <chris@prolocation.net>,
	Mark Nipper <nipsy@bitgnome.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, jesse.brandeburg@intel.com,
	jrlundgren@gmail.com, cat@zip.com.au, djani22@dynamicweb.hu,
	yoseph.basri@gmail.com, mykleb@no.ibm.com, olel@ans.pl,
	michal@feix.cz, netdev@vger.kernel.org, jesse.brandeburg@gmail.com,
	E1000-devel@lists.sourceforge.net, Andi Kleen <ak@suse.de>,
	Jeff Garzik <jgarzik@pobox.com>
Return-path: <e1000-devel-admin@lists.sourceforge.net>
To: "Boris B. Zhmurov" <bb@kernelpanic.ru>
In-Reply-To: <442D45EA.9010309@kernelpanic.ru>
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

Hello, Boris B. Zhmurov.

On 31.03.2006 19:08 you said the following:

> Hmm... with lastest debug patch I can't see any of debug info:

But wait a minute. Two days ago, without Herbert's patches, assertion's 
errors was like this:

Mar 29 20:03:23 msk4 kernel: KERNEL: assertion (!sk->sk_forward_alloc) 
failed at net/core/stream.c (279)
Mar 29 20:03:23 msk4 kernel: KERNEL: assertion (!sk->sk_forward_alloc) 
failed at net/ipv4/af_inet.c (148)


and after appling patches, errors looks like this:

Mar 31 18:21:06 msk4 kernel: KERNEL: assertion (!sk->sk_forward_alloc) 
failed at net/core/stream.c (283)
Mar 31 18:21:06 msk4 kernel: KERNEL: assertion (!sk->sk_forward_alloc) 
failed at net/ipv4/af_inet.c (150)


stream.c (279) -> stream.c (283)
af_inet.c (148) -> af_inet.c (150)


Does it really matters?

-- 
Boris B. Zhmurov
mailto: bb@kernelpanic.ru
"wget http://kernelpanic.ru/bb_public_key.pgp -O - | gpg --import"



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
