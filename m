From: "David S. Miller" <davem@redhat.com>
Subject: Re: [IPV4] Always set hoplimit
Date: Tue, 18 Nov 2003 17:05:33 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031118170533.64f53889.davem@redhat.com>
References: <20031113110438.GA29522@gondor.apana.org.au>
	<20031118165909.788d5388.davem@redhat.com>
	<20031119010827.GA25593@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20031119010827.GA25593@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 19 Nov 2003 12:08:27 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Tue, Nov 18, 2003 at 04:59:09PM -0800, David S. Miller wrote:
> >
> > Did you run into an actual problem that led you to this issue?  If
> > so, what was it?  Or was this just determined by pure code review?
> 
> Someone reported this problem to me after a picky firewall complained
> about getting broadcast packets with ttl == 0.

Ok, that doubly-justifies the fix.

Thanks again Herbert.
