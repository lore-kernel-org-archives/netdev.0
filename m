From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH] gre: fix ToS/DiffServ inherit bug
Date: Tue, 14 Jul 2009 21:28:47 +0400
Message-ID: <20090714172847.GA28917@ms2.inr.ac.ru>
References: <20090714153648.GC8461@urbino.open.ch> <20090714.093433.216171575.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: aj@open.ch, voyo@no-ip.pl, netdev@vger.kernel.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:57329 "HELO ms2.inr.ac.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753247AbZGNR3O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jul 2009 13:29:14 -0400
Content-Disposition: inline
In-Reply-To: <20090714.093433.216171575.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On Tue, Jul 14, 2009 at 09:34:33AM -0700, David Miller wrote:
> Note that this only works out because one wouldn't specify ECN
> bits in the TOS to use for the tunnel.
> 
> But it demonstrates the outright danger of trying to use
> "undefined" flag bits in protocol header fields to pass
> private control flags into the driver from user interfaces.

Yes. My fault.

Well, in the form after the patch it will survive at least until
the next change of semantics of tos. :-)

Alexey
