From: Pablo Neira <pablo@eurodev.net>
Subject: Re: iptables versioning feature causes ABI breakage
Date: Thu, 24 Mar 2005 22:17:05 +0100
Message-ID: <42432E51.1080309@eurodev.net>
References: <1111666300.1037.40.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org,
	Patrick McHardy <kaber@trash.net>, Harald Welte <laforge@gnumonks.org>
To: hadi@znyx.com
In-Reply-To: <1111666300.1037.40.camel@jzny.localdomain>
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

Jamal,

Jamal Hadi Salim wrote:
> Folks,
> 
> Could whoever that made the versioning changes in iptables please
> contact me?

I was also involved in that change together with Rusty around january. 
It's a new infrastructure to extend matches/targets without breaking 
backward compatibility with previous releases of target/matches/iptables.

I must confess that I didn't have a look at your ipt_action stuff before 
, now I did. As Patrick pointed out, we'll keep in mind your ipt thing 
in future.

Your patch for tc to fix the problem looks fine. BTW, you can now use 
extended MARK features like --and-mark and --or-mark ;->

--
Pablo
