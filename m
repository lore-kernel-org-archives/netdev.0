From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: Re: [PATCH 1/2] ne.c fix, res->name
Date: Mon, 01 Sep 2008 02:15:05 +0900 (JST)
Message-ID: <20080901.021505.108307990.anemo@mba.ocn.ne.jp>
References: <20080830024425.GA24929@spacedout.fries.net>
	<20080831.000357.70223885.anemo@mba.ocn.ne.jp>
	<20080830180503.GI25161@spacedout.fries.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, p_gortmaker@yahoo.com,
	netdev@vger.kernel.org
To: david@fries.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mba.ocn.ne.jp ([122.1.235.107]:55939 "EHLO smtp.mba.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753528AbYHaRPF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 31 Aug 2008 13:15:05 -0400
In-Reply-To: <20080830180503.GI25161@spacedout.fries.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 30 Aug 2008 13:05:03 -0500, David Fries <david@fries.net> wrote:
> On Sun, Aug 31, 2008 at 12:03:57AM +0900, Atsushi Nemoto wrote:
> > On Fri, 29 Aug 2008 21:44:25 -0500, David Fries <david@fries.net> wrote:
> > > +	if (!strcmp(res->name, BAD_STR))
> > > +		dev->mem_end = BAD;
> > 
> > The res->name might be NULL.  You should check it first.
> > 
> > 	if (res->name && !strcmp(res->name, BAD_STR))
> > 		dev->mem_end = BAD;
> 
> The name gets a valid string by that point in time.
> 
> drivers/base/platform.c:257

Oh, you are right.  Sorry for noise.

---
Atsushi Nemoto
