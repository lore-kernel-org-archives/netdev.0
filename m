From: Jamal Hadi Salim <hadi@znyx.com>
Subject: Re: iptables versioning feature causes ABI breakage
Date: 25 Mar 2005 17:24:12 -0500
Message-ID: <1111789452.1089.725.camel@jzny.localdomain>
References: <1111666300.1037.40.camel@jzny.localdomain>
	<42432E51.1080309@eurodev.net>
Reply-To: hadi@znyx.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@oss.sgi.com>, netfilter-devel@lists.netfilter.org,
	Patrick McHardy <kaber@trash.net>, Harald Welte <laforge@gnumonks.org>
To: Pablo Neira <pablo@eurodev.net>
In-Reply-To: <42432E51.1080309@eurodev.net>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

On Thu, 2005-03-24 at 16:17, Pablo Neira wrote:
> Jamal,
> 
> Jamal Hadi Salim wrote:
> > Folks,
> > 
> > Could whoever that made the versioning changes in iptables please
> > contact me?
> 
> I was also involved in that change together with Rusty around january. 
> It's a new infrastructure to extend matches/targets without breaking 
> backward compatibility with previous releases of target/matches/iptables.
> 

I think in the future this will go fine; all actions have a version
field as well that is set to 0 at the moment.

> I must confess that I didn't have a look at your ipt_action stuff before 
> , now I did. As Patrick pointed out, we'll keep in mind your ipt thing 
> in future.
> 
> Your patch for tc to fix the problem looks fine. BTW, you can now use 
> extended MARK features like --and-mark and --or-mark ;->
> 

cool.

Would you like to pay for your sins;-> by looking at my code to see it
doesnt break or miss things?

cheers,
jamal
