From: Mitchell Blank Jr <mitch@sfgoth.com>
Subject: Re: ATM bug found
Date: Sun, 1 Oct 2006 08:38:42 -0700
Message-ID: <20061001153842.GD83074@gaz.sfgoth.com>
References: <451FC182.6000502@garzik.org> <200610011514.k91FE3ai003599@cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gaz.sfgoth.com ([69.36.241.230]:12789 "EHLO gaz.sfgoth.com")
	by vger.kernel.org with ESMTP id S1750990AbWJAP0X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Oct 2006 11:26:23 -0400
To: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Content-Disposition: inline
In-Reply-To: <200610011514.k91FE3ai003599@cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

chas williams - CONTRACTOR wrote:
> still generates a warning from gcc though.

The warning is bogus in this case, though -- the only way for "*pcr" to
be unset is when alloc_shaper() returns non-zero

> +		*pcr = 0;

You're right, 0 is better than ATM_MAX_PCR here.

-Mitch
