From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: iproute2 and kernel headers
Date: Tue, 3 Aug 2004 08:31:42 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040803083142.5a4ccaad@dell_ss3.pdx.osdl.net>
References: <20040802153805.487f832f@dell_ss3.pdx.osdl.net>
	<20040803001459.GA8637@irc.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Tomasz Torcz <zdzichu@irc.pl>
In-Reply-To: <20040803001459.GA8637@irc.pl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 3 Aug 2004 02:14:59 +0200
Tomasz Torcz <zdzichu@irc.pl> wrote:

> On Mon, Aug 02, 2004 at 03:38:05PM -0700, Stephen Hemminger wrote:
> > I am willing to put some headers (not all) in with the user level
> > code, provided they are copies since they I can easily update. I don't want
> > to get into keeping an edited set of headers in sync.
> 
>  Aren't linux-libc-headers (*) sufficient?
> 
> * - http://ep09.pld-linux.org/~mmazur/linux-libc-headers/

The theory of that is good, but in practice it would make the problem worse.
What iproute2 wants is to have the same kernel data structures as the latest kernel.
It is awkward enough making sure to get them from the correct kernel sources, but
doing it from a different package would make updating and keeping everything current worse.
