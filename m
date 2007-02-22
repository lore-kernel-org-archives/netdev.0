From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 1/2][TCP] YeAH-TCP: algorithm implementation
Date: Thu, 22 Feb 2007 11:36:36 -0800
Message-ID: <20070222113636.28ba1896@freekitty>
References: <45D97C62.5070406@gmail.com>
	<20070222.001918.55725416.davem@davemloft.net>
	<8dd26e70702220810x21c8d494u1200de1c02d23d57@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	francesco@net.infocom.uniroma1.it, andrea.baiocchi@uniroma1.it
To: "Angelo P. Castellani" <angelo.castellani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:34999 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751788AbXBVTgt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Feb 2007 14:36:49 -0500
In-Reply-To: <8dd26e70702220810x21c8d494u1200de1c02d23d57@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Minor comments:

1. Please move  div64_64 out of yeah-tcp (and cubic where you copied it).
   to asm-generic/div64.h

2. Don't need separate tcp_yeah.h just put it in tcp_yeah.c. Also, maybe
   the vegas stuff you copied should go in one place? tcp/vegas.h?

3. whitespace:
	don't do:
		x+=someexpression
		... = max( x, ...
	instead:
		x += someexpression
		... = max(x, ...
	Using indent script in scripts/Lindent will fix these.

4. See if you can replace uses of min_t and max_t with min and max by having
   proper matching types on args. Basically if you need to cast maybe original
   type was wrong.

