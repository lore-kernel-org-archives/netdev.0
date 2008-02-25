From: David Brownell <david-b@pacbell.net>
Subject: Re: [patch 2.6.25-rc2-git] rndis_host:  fix transfer size negotiation
Date: Mon, 25 Feb 2008 13:11:55 -0800
Message-ID: <20080225211155.3C2181EE67A@adsl-69-226-248-13.dsl.pltn13.pacbell.net>
References: <200802221731.16698.david-b@pacbell.net>
 <20080225182918.GA3094@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jussi.kivilinna@mbnet.fi,
	jcd@tribudubois.net
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp120.sbc.mail.sp1.yahoo.com ([69.147.64.93]:40868 "HELO
	smtp120.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750757AbYBYVL5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2008 16:11:57 -0500
In-Reply-To: <20080225182918.GA3094@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > This patch should resolve a problem that's troubled support for
> > some RNDIS peripherals.  It seems to have boiled down to using a
> > variable to establish transfer size limits before it was assigned,
> > which caused those devices to fallback to a default "jumbogram"
> > mode we don't support.  Fix by assigning it earlier for RNDIS.
>
> Any chance that something like this is appropriate for rndis_wlan?

I'd expect so; but, isn't it already getting that benefit?

- Dave

