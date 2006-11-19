From: David Kimdon <david.kimdon@devicescape.com>
Subject: Re: [PATCH] d80211: fix scan issues with new ops
Date: Sun, 19 Nov 2006 09:25:28 -0800
Message-ID: <20061119172528.GA26466@devicescape.com>
References: <1163802439.3392.47.camel@johannes.berg> <1163895673.15473.11.camel@johannes.berg> <20061119155628.GA25061@devicescape.com> <1163954089.15473.16.camel@johannes.berg> <20061119165521.GB25557@devicescape.com> <1163955459.15473.28.camel@johannes.berg>
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
Received: from mail.devicescape.com ([207.138.119.2]:42969 "EHLO
	mail.devicescape.com") by vger.kernel.org with ESMTP
	id S1756801AbWKSRZb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Nov 2006 12:25:31 -0500
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <1163955459.15473.28.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Nov 19, 2006 at 05:57:39PM +0100, Johannes Berg wrote:
> On Sun, 2006-11-19 at 08:55 -0800, David Kimdon wrote:
> 
> > ok.  I am concerned that making this split between per driver and per
> > card is difficult to get right.  Setting or not setting a function
> > pointer for an operation is fairly standard practice and I don't see
> > the value in introducing yet another way to indicate support.
> 
> I guess we can punt this patch until some driver shows up that actually
> has some cards that need the function and some that don't. I'm actually
> guessing such a driver won't exist but wanted this for completeness in
> the split between _wiphy and _ops.

Perhaps that is a split that we do not need?  I don't see the problem
that 'd80211: split ieee80211_hw' is solving.  I do see what it is
doing, but maybe I am missing something . . .  

> 
> johannes


