From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: [e1000 debug] KERNEL: assertion (!sk_forward_alloc) failed...
Date: Wed, 5 Apr 2006 15:05:28 -0700 (Pacific Daylight Time)
Message-ID: <Pine.WNT.4.63.0604051500530.2496@jbrandeb-desk.amr.corp.intel.com>
References: <20060330101218.GA2905@gondor.apana.org.au> <442BDD25.1060000@kernelpanic.ru>
 <20060331.011245.26474207.davem@davemloft.net> <442D0186.8090705@kernelpanic.ru>
 <20060331103956.GA12181@gondor.apana.org.au> <442D1B67.8000804@kernelpanic.ru>
 <20060331121007.GA2146@king.bitgnome.net> <442D1F26.8050601@kernelpanic.ru>
 <20060331123514.GA13500@gondor.apana.org.au> <20060403210123.GA27698@king.bitgnome.net>
 <20060403213907.GA32406@linuxace.com> <44319AFF.4090101@kernelpanic.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Phil Oester <kernel@linuxace.com>,
	Mark Nipper <nipsy@bitgnome.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	jrlundgren@gmail.com, cat@zip.com.au, djani22@dynamicweb.hu,
	yoseph.basri@gmail.com, mykleb@no.ibm.com, olel@ans.pl,
	michal@feix.cz, chris@scorpion.nl, netdev@vger.kernel.org,
	jesse.brandeburg@gmail.com, E1000-devel@lists.sourceforge.net,
	Andi Kleen <ak@suse.de>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <e1000-devel-admin@lists.sourceforge.net>
To: "Boris B. Zhmurov" <bb@kernelpanic.ru>
In-Reply-To: <44319AFF.4090101@kernelpanic.ru>
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



On Mon, 3 Apr 2006, Boris B. Zhmurov wrote:

> 
> Hello, Phil Oester.
> 
> On 04.04.2006 01:39 you said the following:
> 
> > On Mon, Apr 03, 2006 at 04:01:23PM -0500, Mark Nipper wrote:
> >
> >>        After three days and some hours, I finally saw another
> >>event:
> >
> >
> > Ack, same here.  Looked hopeful, but finally saw the error today.
> >
> > Phil
> 
> 
> [root@msk4 ~]# dmesg |grep assertion |wc -l
> 176
> 
> [root@msk4 ~]# uptime
>   02:00:01 up 3 days,  7:31,  2 users,  load average: 1.32, 0.59, 0.41
> 

Some earlier had proposed that this problem appeared in 2.6.12, which was 
the introduction of the 6.X series e1000 driver.

If someone would like to, can they try the 5.6.10.1 driver from the 
2.6.11.X kernel?

I'd like it if you can stick with your current kernel, and if you have 
trouble building the driver, go ahead and try the 5.6.10.1 driver from 
http://prdownloads.sf.net/e1000

I'll also send a patch today to back-rev the xmit routine to the 5.6.10.1 
state.

Jesse


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
