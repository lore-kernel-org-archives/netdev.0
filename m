From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] d80211: fix some 0 vs. NULL comparisons
Date: Mon, 14 Aug 2006 15:20:58 +0200
Message-ID: <44E078BA.5010707@sipsolutions.net>
References: <44E02F41.2060300@sipsolutions.net> <44E030B8.2000600@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jouni Malinen <jkm@devicescape.com>, Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:4004 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751280AbWHNNVj
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Aug 2006 09:21:39 -0400
To: netdev@vger.kernel.org
In-Reply-To: <44E030B8.2000600@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Johannes Berg wrote:
> -    if (!local->hw->passive_scan) {
> +    if (local->hw->passive_scan == NULL) {

Alright, this is icky. I'll make another pass and change it all to if 
(x) or if (!x) instead of comparing to NULL. Don't hold your breath 
though, earliest next weekend.

johannes
