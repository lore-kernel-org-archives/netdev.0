From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Wrong UIDs reported in /proc/net/tcp
Date: Thu, 18 Nov 2004 13:27:00 -0800
Message-ID: <20041118132700.29c23d00@zqx3.pdx.osdl.net>
References: <20041109205358.GA64015@calma.pair.com>
	<E1CRdBr-0001P2-00@gondolin.me.apana.org.au>
	<20041118190257.GA7084@calma.pair.com>
	<20041118210307.GA9557@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Chad N. Tindel" <chad@tindel.net>, netdev@oss.sgi.com,
        linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20041118210307.GA9557@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 19 Nov 2004 08:03:07 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Thu, Nov 18, 2004 at 02:02:57PM -0500, Chad N. Tindel wrote:
> > 
> > OK, so just out of sheer morbid curiousity, I added an ioctl which will
> > accept 4 parameters (the address/port pairs), and will return the user id
> > associated with that socket.  I also changed pidentd to call this ioctl
> > instead of looking at /proc/net/tcp.  This should theoretically get rid
> > of all race conditions.
> 
> Please show us the code of your ioctl.
> 
> Have you tried netlink yet? Does it exhibit the same problem?

It could also be the sockets are shared between processes with uid's or that
the real/effective uid or different or even the uid is that of the original
creator and the file was inherited across exec.
