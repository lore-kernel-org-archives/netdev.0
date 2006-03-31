From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [e1000 debug] KERNEL: assertion (!sk_forward_alloc) failed...
Date: Fri, 31 Mar 2006 01:12:45 -0800 (PST)
Message-ID: <20060331.011245.26474207.davem@davemloft.net>
References: <442BAC99.2090404@kernelpanic.ru>
	<20060330101218.GA2905@gondor.apana.org.au>
	<442BDD25.1060000@kernelpanic.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, jesse.brandeburg@intel.com,
	nipsy@bitgnome.net, jrlundgren@gmail.com, cat@zip.com.au,
	djani22@dynamicweb.hu, yoseph.basri@gmail.com, mykleb@no.ibm.com,
	olel@ans.pl, michal@feix.cz, chris@scorpion.nl,
	netdev@vger.kernel.org, jesse.brandeburg@gmail.com,
	E1000-devel@lists.sourceforge.net
Return-path: <e1000-devel-admin@lists.sourceforge.net>
To: bb@kernelpanic.ru
In-Reply-To: <442BDD25.1060000@kernelpanic.ru>
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

From: "Boris B. Zhmurov" <bb@kernelpanic.ru>
Date: Thu, 30 Mar 2006 17:29:09 +0400

> Hello, Herbert Xu.
> 
> On 30.03.2006 14:12 you said the following:
> 
> > On Thu, Mar 30, 2006 at 10:02:01AM +0000, Boris B. Zhmurov wrote:
> > 
> >>[zhmurov@builds linux-2.6.16]$ patch -p1 < 
> >>../../../SOURCES/linux-2.6.16-e1000-try-to-fix-assertion_sk_forward_alloc_failed_by_Herbert_Xu.patch 
> >>
> >>patching file drivers/net/e1000/e1000_main.c
> >>Reversed (or previously applied) patch detected!  Assume -R? [n]
> >>
> >>Herbert, is that patch already included in 2.6.16.1?
> > 
> > 
> > Not really.  It's just patch being silly (or too smart :)
> > 
> > Here it is again rediffed against 2.6.16.
> 
> 
> Nope, with this patch the problem still exists. After 25 min. uptime 
> with patched kernel 2.6.16.1, I have:

Can you please double and triple check that you're really running a
kernel with the fix from Herbert applied?  I make this mistake all
the time :-)

Thanks.



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
