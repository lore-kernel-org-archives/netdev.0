From: jamal <hadi@cyberus.ca>
Subject: Re: iptables versioning feature causes ABI breakage
Date: 24 Mar 2005 07:46:04 -0500
Message-ID: <1111668363.1039.64.camel@jzny.localdomain>
References: <1111666300.1037.40.camel@jzny.localdomain>
	<20050324123305.GE18694@sunbeam.de.gnumonks.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org,
	Patrick McHardy <kaber@trash.net>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20050324123305.GE18694@sunbeam.de.gnumonks.org>
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

On Thu, 2005-03-24 at 07:33, Harald Welte wrote:

> > versions;->). In the future please please remember there are other
> > users of these goods other than iptables.
> 
> well, the versioning was developed about the same time that you got your
> tc interface included, if I'm not mistaken.

You are probably correct.
The tc code has been around since about 2.6.8 and the ipt code probably
went in around 2.6.9/10; there has been fixes made to net/sched/ipt.c
when general interfaces were changed i cant rememember what that was.. 

In any case, we can make it better going forward to reduce maintainance
overhead on my part. As i was saying earlier - I am stealing a lot of
the code from iptables - so if it is that shareable, maybe it could be
converted to a library.

cheers,
jamal
