From: "Jouni Malinen" <jkm@devicescape.com>
Subject: Re: [PATCH] d80211: fix some 0 vs. NULL comparisons
Date: Mon, 14 Aug 2006 08:48:13 -0700
Message-ID: <20060814154813.GA1196@instant802.com>
References: <44E02F41.2060300@sipsolutions.net> <44E030B8.2000600@sipsolutions.net> <44E078BA.5010707@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-66.dex002.intermedia.net ([64.78.20.24]:24895 "EHLO
	DHOST002-66.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1751267AbWHNPuL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Aug 2006 11:50:11 -0400
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <44E078BA.5010707@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 14, 2006 at 03:20:58PM +0200, Johannes Berg wrote:
> Johannes Berg wrote:
> >-    if (!local->hw->passive_scan) {
> >+    if (local->hw->passive_scan == NULL) {
> 
> Alright, this is icky. I'll make another pass and change it all to if 
> (x) or if (!x) instead of comparing to NULL. Don't hold your breath 
> though, earliest next weekend.

Well.. I'm perfectly fine with comparing function pointers to NULL in
this kind of case.. In many cases, I find fp == NULL to be clearer than
!fp, but for the fp != NULL case I would rather not see != NULL.. Not
very consistent, but can't really help with that on this kind of coding
style opinions. Anyway, replacing 0 with NULL is a good change.

-- 
Jouni Malinen                                            PGP id EFC895FA
