From: David Kimdon <david.kimdon@devicescape.com>
Subject: Re: [PATCH] d80211: fix scan issues with new ops
Date: Sun, 19 Nov 2006 07:56:28 -0800
Message-ID: <20061119155628.GA25061@devicescape.com>
References: <1163802439.3392.47.camel@johannes.berg> <1163895673.15473.11.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Simon Barber <simon@devicescape.com>,
	Jouni Malinen <jkm@devicescape.com>,
	Hong Liu <hong.liu@intel.com>,
	David Kimdon <david.kimdon@devicescape.com>,
	Michael Wu <flamingice@sourmilk.net>,
	Michael Buesch <mbuesch@freenet.de>,
	Ivo van Doorn <ivdoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.devicescape.com ([207.138.119.2]:42696 "EHLO
	mail.devicescape.com") by vger.kernel.org with ESMTP
	id S1756731AbWKSP4i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Nov 2006 10:56:38 -0500
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <1163895673.15473.11.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Nov 19, 2006 at 01:21:13AM +0100, Johannes Berg wrote:
> If hardware shall do scanning, the hw_scan operation must be set. However,
> if the driver is for multiple cards that may or may not do hardware
> scanning, it'll need a flag.

What is wrong with the driver setting the function pointer to NULL for
the cards that do not support scanning?  Where does this requirment
come from that the function pointers in struct ieee80211_wiphy be
identical for all cards?

-David
