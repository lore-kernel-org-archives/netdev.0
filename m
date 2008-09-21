From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Mark IPW2100 as BROKEN: Fatal interrupt. Scheduling firmware restart.
Date: Sun, 21 Sep 2008 22:28:38 +0400
Message-ID: <20080921182835.GA11473@2ka.mipt.ru>
References: <20080921172316.GA6306@2ka.mipt.ru> <20080921110422.1d010b96@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ipw2100-devel@lists.sourceforge.net,
	linux-wireless@vger.kernel.org, yi.zhu@intel.com,
	reinette.chatre@intel.com, jgarzik@pobox.com,
	linville@tuxdriver.com, davem@davemloft.net
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:38758 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750996AbYIUS36 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Sep 2008 14:29:58 -0400
Content-Disposition: inline
In-Reply-To: <20080921110422.1d010b96@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 21, 2008 at 11:04:22AM -0700, Arjan van de Ven (arjan@infradead.org) wrote:
> so now you go from an occasional burp to having nothing at all.
> How about you run with this patch on your own machine only?

And how else user can get attention to the problem which is not fixed by
the vendor? We close our eyes and there is no problem, since we do not
see it. I just brought a lamp: no user can see that essentially driver
is broken so he can run it on his own risk.

> or.. since you say a reload of the driver fixes it.. why don't you make
> a patch for the driver that does basically the actions of a reload
> automatically when the driver detects the issue?
> (and stick a WARN_ON in for good measure so that kerneloops.org can
> start tracking these burps)

It stops after several seconds (or packets?). Sometimes (but rarely)
it works several minutes, sometimes it fires above dmesg line and
continues to work, sometimes it fires it for a while and then stops
writing it, although driver does not send or receive anything (at
least ifconfig counters do not change).

Actually, I do not think it is a driver problem, since what it does is
pretty much straightforward, but if you will tell me how else can we fix
this issue, I will print it and glue near the window so this gotcha
could be used with other problems. Or you can (as everyone else who do)
just said that this is damn wrong and forget about problem for the next
several years.

-- 
	Evgeniy Polyakov
