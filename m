From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 2/2] ne.c msleep not mdelay
Date: Sat, 30 Aug 2008 09:59:06 +0100
Message-ID: <20080830095906.6cad8647@lxorguk.ukuu.org.uk>
References: <20080830024453.GB24929@spacedout.fries.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Atsushi Nemoto <anemo@mba.ocn.ne.jp>,
	p_gortmaker@yahoo.com, netdev@vger.kernel.org
To: David Fries <david@fries.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:50378 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750777AbYH3JQb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Aug 2008 05:16:31 -0400
In-Reply-To: <20080830024453.GB24929@spacedout.fries.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 29 Aug 2008 21:44:53 -0500
David Fries <david@fries.net> wrote:

> mdelay(10) replaced by msleep(10) to give up the CPU, it's just
> waiting for an interrupt, so timing isn't critical.

It is too critical for a reschedule to occur.

NAK this one.
