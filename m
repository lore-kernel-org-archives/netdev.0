From: "David S. Miller" <davem@redhat.com>
Subject: Re: [RFC, PATCH 5/5]: netfilter+ipsec - policy checks
Date: Thu, 18 Mar 2004 22:19:04 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040318221904.45011167.davem@redhat.com>
References: <20040308110331.GA20719@gondor.apana.org.au>
	<404C874D.4000907@trash.net>
	<20040308115858.75cdddca.davem@redhat.com>
	<4059CF27.4030803@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@oss.sgi.com,
        netfilter-devel@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <4059CF27.4030803@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 18 Mar 2004 17:32:39 +0100
Patrick McHardy <kaber@trash.net> wrote:

> This patch makes xfrm_policy_check locate the correct policy after NAT.
> For protocols which do policy checks in their receive routines the
> reference to nfct has to be kept until policy checks are done, the
> other ones still drop it in ip_local_deliver_finish.

This patch looks fine to me.

Other than the minor comments I've made the most unhappy I am
with the input patch, and you agree it's grotty too.  Let's look
for a better solution, perhaps with new top-level SKB state,
and then we can put all of your work in after you're made the other
minor fixes I've asked for as well.

Thanks Patrick.
