From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: Re: [PATCH] ne.c fix for hibernate and rmmod oops fix
Date: Thu, 11 Sep 2008 22:50:48 +0900 (JST)
Message-ID: <20080911.225048.25909971.anemo@mba.ocn.ne.jp>
References: <20080904030212.GA23493@spacedout.fries.net>
	<7d1d9c250809050101v9ab3907l649781ee38a5a243@mail.gmail.com>
	<20080909025434.GB28469@spacedout.fries.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul.gortmaker@gmail.com, akpm@linux-foundation.org,
	p_gortmaker@yahoo.com, alan@lxorguk.ukuu.org.uk, jeff@garzik.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: david@fries.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mba.ocn.ne.jp ([122.1.235.107]:53052 "EHLO smtp.mba.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755706AbYIKNup (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Sep 2008 09:50:45 -0400
In-Reply-To: <20080909025434.GB28469@spacedout.fries.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 8 Sep 2008 21:54:34 -0500, David Fries <david@fries.net> wrote:
> Now that the io port and irq can be looked up in the arrays the probe
> code doesn't even need the resources passed by the platform device.
> The ne.c driver already registers the resources it needs and there
> isn't any good way to update the resources when the io port or irq are
> zero and probed at runtime.

No, please don't.  This breaks current users of ne platform driver.
For example, please look at rbtx4927_ne_init() in
arch/mips/txx9/rbtx4927/setup.c file.

---
Atsushi Nemoto
