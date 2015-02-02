From: David Miller <davem@davemloft.net>
Subject: Re: Is sch_teql still useful?
Date: Sun, 01 Feb 2015 22:27:41 -0800 (PST)
Message-ID: <20150201.222741.1721645652546390344.davem@davemloft.net>
References: <CAHA+R7NDfn705P0OrgpMfx7nbsNcHh-cXrPVQezG9WtH1Ya3Yg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, netdev@vger.kernel.org,
	stephen@networkplumber.org
To: cwang@twopensource.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42186 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932592AbbBBG1m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 01:27:42 -0500
In-Reply-To: <CAHA+R7NDfn705P0OrgpMfx7nbsNcHh-cXrPVQezG9WtH1Ya3Yg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <cwang@twopensource.com>
Date: Fri, 30 Jan 2015 20:23:32 -0800

> Since we have bonding alb, is it still needed to have sch_teql since
> they do the same thing, load balancing over multiple interfaces? Also
> sch_teql mixes netdevice with qdisc, which somewhat breaks the
> abstraction?
> 
> I don't dig the history so I could easily miss something here.

I can't comment as to it's usefulness, but I will note that we don't
have the option of removing it if you are thinking about doing so.
