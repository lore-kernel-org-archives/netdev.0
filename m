From: "David S. Miller" <davem@redhat.com>
Subject: Re: [RFC, PATCH 2/5]: netfilter+ipsec - output hooks
Date: Thu, 18 Mar 2004 22:09:57 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040318220957.35870744.davem@redhat.com>
References: <20040308110331.GA20719@gondor.apana.org.au>
	<404C874D.4000907@trash.net>
	<20040308115858.75cdddca.davem@redhat.com>
	<4059CEEC.7070009@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@oss.sgi.com,
        netfilter-devel@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <4059CEEC.7070009@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


This one isn't going to compile with netfilter disabled, I can tell
just by looking at it :-)

The reason is that NF_HOOK_COND is defined to NF_HOOK in that case,
and these two macros take a different number of args so the compiler
is going to barf.
