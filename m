From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: rfc: checkpatch logical line continuations
Date: Fri, 07 Mar 2014 16:23:41 -0500 (EST)
Message-ID: <20140307.162341.1600860024275495539.davem@davemloft.net>
References: <1394077948-8395-3-git-send-email-alistair@popple.id.au>
	<20140307.154142.488351276799532264.davem@davemloft.net>
	<1394226164.16156.96.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alistair-Y4h6yKqj69EXC2x5gXVKYQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	error27-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org, randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
To: joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1394226164.16156.96.camel@joe-AO722>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Date: Fri, 07 Mar 2014 13:02:44 -0800

> Right now, checkpatch emits a --strict only warning on "&&" or "||"
> at the beginning of line but that could be changed to any "$Operators"
> 
> our $Arithmetic = qr{\+|-|\*|\/|%};
> our $Operators	= qr{
> 			<=|>=|==|!=|
> 			=>|->|<<|>>|<|>|!|~|
> 			&&|\|\||,|\^|\+\+|--|&|\||$Arithmetic
> 		  }x;
> 
> The ones that likely have a too high false positive rates
> are the negation "!" and bitwise "~".

Unary operators at the beginning of a line are perfectly fine,
it's the other ones that are the problem.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
