From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 2/3] drivers/staging/rtl8192e: Don't pass huge struct by
 value
Date: Tue, 23 Aug 2011 12:08:34 -0700
Message-ID: <20110823190834.GC17796@kroah.com>
References: <alpine.LNX.2.00.1108130058310.7387@swampdragon.chaosbits.net>
 <4E45B684.6080300@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesper Juhl <jj@chaosbits.net>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org,
	Mike McCormack <mikem@ring3k.org>,
	Lucas De Marchi <lucas.demarchi@profusion.mobi>,
	Stefan Weil <weil@mail.berlios.de>,
	Andrea Merello <andreamrl@tiscali.it>, netdev@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3.smtp.messagingengine.com ([66.111.4.27]:49154 "EHLO
	out3.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755304Ab1HWTLE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2011 15:11:04 -0400
Content-Disposition: inline
In-Reply-To: <4E45B684.6080300@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 12, 2011 at 06:25:56PM -0500, Larry Finger wrote:
> On 08/12/2011 06:04 PM, Jesper Juhl wrote:
> >From: Jesper Juhl<jj@chaosbits.net>
> >Date: Sat, 13 Aug 2011 00:52:32 +0200
> >
> >struct ieee80211_network is fairly large (more than half a kilobyte),
> >so let's pass a pointer instead of passing the entire structure by
> >value when ieee80211_is_54g() and ieee80211_is_shortslot() need to
> >look at a few members.
> >Also remove parentheses around the values being returned from those
> >two functions - 'return' is not a function.
> >
> >Signed-off-by: Jesper Juhl<jj@chaosbits.net>
> >---
> >  drivers/staging/rtl8192e/ieee80211/ieee80211.h     |    4 ++--
> >  .../staging/rtl8192e/ieee80211/ieee80211_softmac.c |   14 +++++++-------
> >  2 files changed, 9 insertions(+), 9 deletions(-)
> 
> This patch is a good one; however, in Greg's pile of unmerged
> patches is a completely different driver for the RTL8192E. The new
> driver has the advantage of being organized much more like the
> drivers in rtlwifi. That will make it easier to convert to mac80211
> and move to mainline.
> 
> I also have a lot of unsubmitted patches to clean up the code in the
> new driver. At the moment, it is clear of 'checkpatch -f' errors,
> and most warnings. In addition, many of the sparse warnings are
> fixed. Once Greg merges the patches already submitted, I will send
> the others.

Ick, I give up.

Larry, can you resend me _all_ pending rtl8192e patches that you have
sent me that I should apply, in the order they should be applied in, as
I'm totally lost here and have now flushed all of the rtl8192e patches
that were in my inboxes out so I can start with a clean slate.

Sorry about this, the different versions of patches floating around
didn't help anything :(

greg k-h
