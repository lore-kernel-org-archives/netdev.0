From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: PF_RING: Include in main line kernel?
Date: Sun, 18 Oct 2009 18:18:26 +0400
Message-ID: <20091018141826.GA12085@ioremap.net>
References: <8B385E10-4BE2-48A6-BDE0-0AA1A603275E@ntop.org> <20091014203640.GB32317@ioremap.net> <4AD64251.50903@candelatech.com> <20091014.144923.112167161.davem@davemloft.net> <20091018124337.GE27747@prithivi.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, greearb@candelatech.com,
	deri@ntop.org, shemminger@vyatta.com, brad.doctor@gmail.com,
	netdev@vger.kernel.org
To: Harald Welte <laforge@gnumonks.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tservice.net.ru ([195.178.208.66]:57896 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754469AbZJROSX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Oct 2009 10:18:23 -0400
Content-Disposition: inline
In-Reply-To: <20091018124337.GE27747@prithivi.gnumonks.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 18, 2009 at 02:43:37PM +0200, Harald Welte (laforge@gnumonks.org) wrote:
> How does it make it any easier?  Even right now you can implement an entire
> protocol family in your own module, either by registering as netpoll handler,
> or even using the regular dev_add_pack().

Well, it does, since packet will be processed by the main stack after
that, and module will work with the copy only. But I agree that this is
a weak argument.

If it is still a blocking one, what about implementing additional
gpl-only list of handlers which will have 'consumed' skb check? I
believe it would be enough to put it only in single place after the
bridge?

-- 
	Evgeniy Polyakov
