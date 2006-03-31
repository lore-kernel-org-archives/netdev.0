From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [e1000 debug] KERNEL: assertion (!sk_forward_alloc) failed...
Date: Fri, 31 Mar 2006 01:35:40 -0800 (PST)
Message-ID: <20060331.013540.95485284.davem@davemloft.net>
References: <200603311057.07213.netdev@axxeo.de>
	<E1FPFkT-0002om-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@axxeo.de, jesse.brandeburg@intel.com, nipsy@bitgnome.net,
	jrlundgren@gmail.com, cat@zip.com.au, djani22@dynamicweb.hu,
	yoseph.basri@gmail.com, bb@kernelpanic.ru, mykleb@no.ibm.com,
	olel@ans.pl, michal@feix.cz, chris@scorpion.nl,
	netdev@vger.kernel.org, jesse.brandeburg@gmail.com,
	E1000-devel@lists.sourceforge.net
Return-path: <e1000-devel-admin@lists.sourceforge.net>
To: herbert@gondor.apana.org.au
In-Reply-To: <E1FPFkT-0002om-00@gondolin.me.apana.org.au>
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

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 31 Mar 2006 20:16:53 +1100

> Ingo Oeser <netdev@axxeo.de> wrote:
> > 
> > More datapoints.
> > 
> > First of all, I don't see the problem, so this is an exclusion data point.
> 
> Great.  I think so far all the configurations that have this problem
> are
> 
> e1000 + SMP + TSO
> 
> Since your machine is not SMP but has the other two things it would
> indicate that this is an SMP race.

He does not have TSO enabled, e1000 disables TSO when on a link speed
slower than gigabit.

You'll see something like the following in your logs:

e1000: eth0: e1000_watchdog_task: 10/100 speed: disabling TSO


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
