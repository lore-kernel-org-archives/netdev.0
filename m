From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2.6.9 2/3] tlan: inline functions should be static + bogus xor
Date: Tue, 19 Oct 2004 02:38:16 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041019003816.GG19714@rei.reeler.org>
References: <20041018140610.6edf1769@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20041018140610.6edf1769@zqx3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> -	return ( ( a && ! b ) || ( ! a && b ) );
> +	return a ^ b;

Did you notice that this leads to a different result if a
or b is greater than 1. Intended?
