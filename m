From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: Re: [PATCH 2/2] ne.c msleep not mdelay
Date: Mon, 01 Sep 2008 02:30:26 +0900 (JST)
Message-ID: <20080901.023026.55145642.anemo@mba.ocn.ne.jp>
References: <20080830095906.6cad8647@lxorguk.ukuu.org.uk>
	<20080830.233647.05599714.anemo@mba.ocn.ne.jp>
	<20080830154447.770aaca0@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: david@fries.net, linux-kernel@vger.kernel.org,
	p_gortmaker@yahoo.com, netdev@vger.kernel.org
To: alan@lxorguk.ukuu.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from mba.ocn.ne.jp ([122.1.235.107]:64663 "EHLO smtp.mba.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753298AbYHaRaY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 31 Aug 2008 13:30:24 -0400
In-Reply-To: <20080830154447.770aaca0@lxorguk.ukuu.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 30 Aug 2008 15:44:47 +0100, Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:
> > So, if rescheduling was dangerous here, we already have potential
> > problems, no?
> 
> Yes we do but I didn't manage to stop the other mistakes getting in when
> they did. If you take a schedule you get results back from the probe_irq
> that tend to suck in other random ISA device events (ISA being edge
> triggered nobody was ever careful about spurious irq)

OK, I see your point.  Thanks.

---
Atsushi Nemoto
