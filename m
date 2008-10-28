From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH 00/09]IPtablestng/Kernel - New Framework For IPtables
Date: Tue, 28 Oct 2008 03:00:44 +0300
Message-ID: <20081028000044.GA16721@ioremap.net>
References: <20081027042834.0BA69C64087@host1.ystp.ac.ir>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netfilter-devel <netfilter-devel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jan Engelhardt <jengelh@medozas.de>,
	David Miller <davem@davemloft.net>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Harald Welte <laforge@gnumonks.org>,
	Eric Leblond <eric@inl.fr>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Amin Azez <azez@ufomechanic.net>
To: hamid jafarian <hamid.jafarian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kandzendo.ru ([195.178.208.66]:39383 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751901AbYJ1AAu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Oct 2008 20:00:50 -0400
Content-Disposition: inline
In-Reply-To: <20081027042834.0BA69C64087@host1.ystp.ac.ir>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Mon, Oct 27, 2008 at 07:58:33AM +0330, hamid jafarian (hamid.jafarian@gmail.com) wrote:
> New Framework for IPtables

Frankly saying your codying style is way out of expected range of
allowed glitches, so it is quite hard to review the whole thing. Please
update it to at least remotely match existing code. Also I noticed you
do not use list iteration functions sometimes and replaces them with
direct access to next/prev pointers, which is not a good idea.

-- 
	Evgeniy Polyakov
