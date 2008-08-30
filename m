From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 2/2] ne.c msleep not mdelay
Date: Sat, 30 Aug 2008 15:58:26 +0100
Message-ID: <20080830155826.06743636@lxorguk.ukuu.org.uk>
References: <20080830024453.GB24929@spacedout.fries.net>
	<20080830095906.6cad8647@lxorguk.ukuu.org.uk>
	<20080830.233647.05599714.anemo@mba.ocn.ne.jp>
	<20080830145746.GG25161@spacedout.fries.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Atsushi Nemoto <anemo@mba.ocn.ne.jp>, linux-kernel@vger.kernel.org,
	p_gortmaker@yahoo.com, netdev@vger.kernel.org
To: David Fries <david@fries.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:44447 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751988AbYH3PPi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Aug 2008 11:15:38 -0400
In-Reply-To: <20080830145746.GG25161@spacedout.fries.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I was just going to make the argument that any task that could be run
> during msleep, could just as easily run on the other cpu in mdelay (if
> there was one).

ISA bus auto-probing doesn't actually work at all well on SMP. The number
of people who have ever been affected by that has always been effectively
nil.

