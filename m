From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] net/bridge: Add missing in6_dev_put in
	br_validate_ipv6
Date: Mon, 6 Jul 2015 13:19:53 +0200
Message-ID: <20150706111952.GC16864@breakpoint.cc>
References: <1435946491-11148-1-git-send-email-julien.grall@citrix.com>
	<20150703204213.GM16529@breakpoint.cc>
	<559A5A0B.4040700@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: wei.liu2@citrix.com, ian.campbell@citrix.com, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org,
	Florian Westphal <fw@strlen.de>, linux-kernel@vger.kernel.org,
	Bernhard Thaler <bernhard.thaler@wvnet.at>,
	xen-devel@lists.xenproject.org, davem@davemloft.net,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: Julien Grall <julien.grall@citrix.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <559A5A0B.4040700@citrix.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Julien Grall <julien.grall@citrix.com> wrote:
> On 03/07/15 21:42, Florian Westphal wrote:
> > I think it makes more sense to use __in6_dev_get() instead which doesn't
> > take a reference.
> 
> __in6_dev_get requires to hold rcu_read_lock or RTNL. My knowledge on
> this code is very limited. Are we sure that one this lock is hold? At
> first glance, I wasn't able to find one.

All netfilter hooks are rcu_read_locked via nf_hook_slow().

BTW, netfilter patches should be sent to netfilter-devel@vger.kernel.org.
