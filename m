From: David Kimdon <david.kimdon@devicescape.com>
Subject: Re: [PATCH] d80211: fix scan issues with new ops
Date: Sun, 19 Nov 2006 08:55:21 -0800
Message-ID: <20061119165521.GB25557@devicescape.com>
References: <1163802439.3392.47.camel@johannes.berg> <1163895673.15473.11.camel@johannes.berg> <20061119155628.GA25061@devicescape.com> <1163954089.15473.16.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Kimdon <david.kimdon@devicescape.com>,
	netdev@vger.kernel.org, Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Simon Barber <simon@devicescape.com>,
	Jouni Malinen <jkm@devicescape.com>,
	Hong Liu <hong.liu@intel.com>,
	Michael Wu <flamingice@sourmilk.net>,
	Michael Buesch <mbuesch@freenet.de>,
	Ivo van Doorn <ivdoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.devicescape.com ([207.138.119.2]:61139 "EHLO
	mail.devicescape.com") by vger.kernel.org with ESMTP
	id S1756782AbWKSQzX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Nov 2006 11:55:23 -0500
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <1163954089.15473.16.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Nov 19, 2006 at 05:34:49PM +0100, Johannes Berg wrote:
> On Sun, 2006-11-19 at 07:56 -0800, David Kimdon wrote:
> 
> > What is wrong with the driver setting the function pointer to NULL for
> > the cards that do not support scanning?  Where does this requirment
> > come from that the function pointers in struct ieee80211_wiphy be
> > identical for all cards?
> 
> Well I want to allow drivers to make assign the 33 function pointers in
> a static structure, and differences between cards must then be handled
> in the non-static part.

ok.  I am concerned that making this split between per driver and per
card is difficult to get right.  Setting or not setting a function
pointer for an operation is fairly standard practice and I don't see
the value in introducing yet another way to indicate support.

-David
