From: "David S. Miller" <davem@redhat.com>
Subject: Re: Check connect address in NETLINK
Date: Mon, 5 Jul 2004 15:46:39 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040705154639.5c827df6.davem@redhat.com>
References: <20040628231439.GA3021@gondor.apana.org.au>
	<20040629082252.GA26866@ms2.inr.ac.ru>
	<20040629084552.GA6202@gondor.apana.org.au>
	<20040629111433.GA28463@ms2.inr.ac.ru>
	<20040629111833.GA22880@gondor.apana.org.au>
	<20040630112751.GA31160@gondor.apana.org.au>
	<20040630120045.GA7973@ms2.inr.ac.ru>
	<20040630120828.GA31498@gondor.apana.org.au>
	<20040630121420.GA8183@ms2.inr.ac.ru>
	<20040630124050.GA1619@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040630124050.GA1619@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 30 Jun 2004 22:40:50 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Wed, Jun 30, 2004 at 04:14:20PM +0400, Alexey Kuznetsov wrote:
> > 
> > cpu 0:				cpu1 (or just preempted cpu)
> > 
> > sk = netlink_lookup(...);
> > 				... closing sk
> > 				netlink_release() clears sk_socket
> > 
> > use sk->sk_socket. Oops.
> 
> Thanks for the example.
> 
> Here is a version that uses sk_state instead.

Applied, thanks Herbert.
