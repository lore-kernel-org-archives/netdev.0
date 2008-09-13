From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/2] ne.c Fix suspend and resume for ISA PnP cards.
Date: Sat, 13 Sep 2008 15:55:40 -0400
Message-ID: <48CC1ABC.3090903@garzik.org>
References: <20080904030212.GA23493@spacedout.fries.net> <7d1d9c250809050101v9ab3907l649781ee38a5a243@mail.gmail.com> <20080909025434.GB28469@spacedout.fries.net> <20080909030114.GC28469@spacedout.fries.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Paul Gortmaker <paul.gortmaker@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Atsushi Nemoto <anemo@mba.ocn.ne.jp>,
	Paul Gortmaker <p_gortmaker@yahoo.com>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Fries <david@fries.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52800 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752639AbYIMTzv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Sep 2008 15:55:51 -0400
In-Reply-To: <20080909030114.GC28469@spacedout.fries.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Fries wrote:
> From: David Fries <david@fries.net>
> 
> A call to pnp_stop_dev and pnp_start_dev now shuts down and
> initializes plug and play devices for suspend and resume.
> 
> Signed-off-by: David Fries <david@fries.net>
> Cc: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
> Cc: Paul Gortmaker <p_gortmaker@yahoo.com>
> Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>
> Cc: Jeff Garzik <jeff@garzik.org>
> ---
>  drivers/net/ne.c |    9 ++++++++-
>  1 files changed, 8 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/ne.c b/drivers/net/ne.c
> index 2bece66..cd31e77 100644

applied


