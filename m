From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: proposal for new wireless configuration API
Date: Wed, 16 Aug 2006 09:14:24 +0200
Message-ID: <1155712464.3600.10.camel@ux156>
References: <1155655728.17742.30.camel@ux156>
	 <200608151838.58182.mb@bu3sch.de>
	 <1155665688.8940.10.camel@localhost.localdomain>
	 <200608152113.23697.mb@bu3sch.de>
	 <1155671994.19284.13.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>, netdev@vger.kernel.org,
	Jean Tourrilhes <jt@hpl.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:26020 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1750956AbWHPHOF
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Aug 2006 03:14:05 -0400
To: Dan Williams <dcbw@redhat.com>
In-Reply-To: <1155671994.19284.13.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-08-15 at 15:59 -0400, Dan Williams wrote:

> Ok, so if somebody magically opens up new unlicensed ISM spectrum
> around, say, 7GHz, does that space get broken into channels and assigned
> specific numbers by the IEEE?
> 
> I know there are stable channel #s for abg range.  What about the
> future? [1]  Can we guarantee that whenever new spectrum opens up that
> future 802.11 products may use, that the mappings are well-defined?
> 
> That was my main question.

I'd expect them to actually break it into channels and assign channel
numbers. Or whoever creates the hardware first does it, and those
numbers then get adopted in the year-long specification process ;)

Besides, if we really really really needed something else later for
whatever weird reason, we could add a new attribute for those cases, and
have it reject the channel attribute then :)

johannes
