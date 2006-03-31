From: "Christiaan den Besten" <chris@prolocation.net>
Subject: Re: [e1000 debug] KERNEL: assertion (!sk_forward_alloc) failed...
Date: Fri, 31 Mar 2006 15:12:30 +0200
Message-ID: <045601c654c4$c3dece80$3d64880a@speedy>
References: <442BAC99.2090404@kernelpanic.ru> <20060330101218.GA2905@gondor.apana.org.au> <442BDD25.1060000@kernelpanic.ru> <20060331.011245.26474207.davem@davemloft.net> <442D0186.8090705@kernelpanic.ru> <20060331103956.GA12181@gondor.apana.org.au> <442D1B67.8000804@kernelpanic.ru> <20060331121007.GA2146@king.bitgnome.net> <442D1F26.8050601@kernelpanic.ru> <442D24AA.8080609@kernelpanic.ru>
Reply-To: "Christiaan den Besten" <chris@prolocation.net>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=response
Content-Transfer-Encoding: 7bit
Cc: "Mark Nipper" <nipsy@bitgnome.net>,
	"Herbert Xu" <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>,
	<jesse.brandeburg@intel.com>, <jrlundgren@gmail.com>,
	<cat@zip.com.au>, <djani22@dynamicweb.hu>, <yoseph.basri@gmail.com>,
	<mykleb@no.ibm.com>, <olel@ans.pl>, <michal@feix.cz>,
	<netdev@vger.kernel.org>, <jesse.brandeburg@gmail.com>,
	<E1000-devel@lists.sourceforge.net>, "Andi Kleen" <ak@suse.de>,
	"Jeff Garzik" <jgarzik@pobox.com>
Return-path: <e1000-devel-admin@lists.sourceforge.net>
To: "Boris B. Zhmurov" <bb@kernelpanic.ru>
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

Hi !

> P.S. I have another high-load server as gateway. Same distro, same kernels, but less memory (512Mb lowmem). eth0 up - e100, eth1 
> up - e1000. No errors at all! It kinda looks like assertions happens on systems, where the _only_ interface _eth1_ e1000 is up.

No, we have a couple gateway's asserting.

2x : Usenet feeder : Onboard eth0 and eth1 "Ethernet controller: Intel Corporation 82546GB Gigabit Ethernet Controller (rev 03)" -> 
asserts (lot's of disk activity (writes) as well by the way ... ). SMP, 4Gb RAM. (2.6.14-mm2)

4x : Usenet cache : PCI-X eth0 "Ethernet controller: Intel Corporation 82545GM Gigabit Ethernet Controller (rev 04)" -> no asserts 
(no disk activity). Has 2 extra onboard e1000's, but are not used (Ethernet controller: Intel Corporation 82541GI/PI Gigabit 
Ethernet Controller). SMP, 2Gb RAM (2.6.15.1)

bye,
Chris



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
