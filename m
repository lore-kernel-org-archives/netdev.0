From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: Possible fix
Date: Wed, 5 Mar 2014 13:20:09 +0100
Message-ID: <20140305122009.GR32371@secunet.com>
References: <20140227151954.GA30946@redhat.com>
 <20140228072333.GP32371@secunet.com>
 <5310607F.7030401@redhat.com>
 <8608950.OLpq4oFFJB@sifl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Nikolay Aleksandrov <nikolay@redhat.com>, <netdev@vger.kernel.org>,
	Dave Jones <davej@redhat.com>, Fan Du <fan.du@windriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	<linux-security-module@vger.kernel.org>
To: Paul Moore <paul@paul-moore.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <8608950.OLpq4oFFJB@sifl>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 28, 2014 at 05:10:47PM -0500, Paul Moore wrote:
> On Friday, February 28, 2014 11:10:07 AM Nikolay Aleksandrov wrote:
> > On 02/28/2014 08:23 AM, Steffen Klassert wrote:
> > > 
> > > Looking at the git history, it seems that this bug is about nine
> > > years old. I guess noone is actually using this.
> 
> Most (all?) of the labeled IPsec users use the netlink interface and not pfkey 
> so it isn't surprising that this has gone unnoticed for some time.

Right, that's not really surprising. But it is a bit surprising that
we care for the security context only if we add a socket policy via
the pfkey key manager. The security context is not handled if we do
that with the netlink key manager, see xfrm_compile_policy().

I'm not that familiar with selinux and labeled IPsec, but maybe this
needs to be implemented in xfrm_compile_policy() too.
