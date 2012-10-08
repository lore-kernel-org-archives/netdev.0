From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [STABLE][3.0][3.2][Add PATCH] phy/fixed: use an unique MDIO bus name
Date: Mon, 08 Oct 2012 14:52:32 +0200
Message-ID: <1880302.7oo5JroP03@flexo>
References: <1349441987.6755.45.camel@gandalf.local.home> <20121007.145622.83624305358947187.davem@davemloft.net> <1349699954.6755.110.camel@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7Bit
Cc: David Miller <davem@davemloft.net>, ben@decadent.org.uk,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org,
	gregkh@linuxfoundation.org, netdev@vger.kernel.org
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:44534 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750876Ab2JHMxj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2012 08:53:39 -0400
In-Reply-To: <1349699954.6755.110.camel@gandalf.local.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 08 October 2012 08:39:14 Steven Rostedt wrote:
> On Sun, 2012-10-07 at 14:56 -0400, David Miller wrote:
> 
> > But this change impacted a lot of MDIO drivers and there were
> > regressions that needed to be fixed up the first time this stuff
> > went in.
> 
> If it's that big of a deal then we can forget about this fix. I can get
> around it if I tweak my config. Probably just skip the MDIO stuff.

Yes, I think you can just drop the change considering the number of depending 
commits.
--
Florian
