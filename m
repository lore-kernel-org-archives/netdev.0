From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Fw: [Bugme-new] [Bug 4138] New: ipsec with racoon in transport
 mode with esp and ah hangs (problem is in xfrm_state_add)
Date: Mon, 31 Jan 2005 12:36:36 -0800
Message-ID: <20050131123636.7eb3455c.davem@davemloft.net>
References: <20050130224404.5f78d28a.akpm@osdl.org>
	<E1CvZCT-00017g-00@gondolin.me.apana.org.au>
	<20050131114004.6c61cdc1.davem@davemloft.net>
	<20050131202608.GA8794@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, au@unterluggauer.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050131202608.GA8794@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 1 Feb 2005 07:26:08 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> I'm not sure that there is a loop.  Apart from the word hang in the
> subject line, the submitter didn't talk about a loop at all.
> 
> Perhaps he's referring to the loop where the kernel continuously
> sends acquire messages to racoon but racoon responds by doing
> duplicate adds thus deleting the larval SAs?

Ok, that's a different case, the loop is in userspace there.
