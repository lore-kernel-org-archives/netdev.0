From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 2.6.9 2/3] tlan: inline functions should be static +
 bogus xor
Date: Tue, 19 Oct 2004 11:16:51 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041019111651.10c5f3ec@zqx3.pdx.osdl.net>
References: <20041018140610.6edf1769@zqx3.pdx.osdl.net>
	<20041019003816.GG19714@rei.reeler.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041019003816.GG19714@rei.reeler.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 19 Oct 2004 02:38:16 +0200
Thomas Graf <tgraf@suug.ch> wrote:

> > -	return ( ( a && ! b ) || ( ! a && b ) );
> > +	return a ^ b;
> 
> Did you notice that this leads to a different result if a
> or b is greater than 1. Intended?

I am redoing the tlan patch series.  There is actually a better implementation
of the mcast hash already in the code but #ifdef'd out. Tested it and it generates the
same values. So the whole old xor code just goes away...
