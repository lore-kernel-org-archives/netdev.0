From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 2/7] d80211: add support for SIOCSIWRATE and SIOCGIWRATE
Date: Wed, 18 Oct 2006 15:42:11 +0200
Message-ID: <1161178931.5575.27.camel@ux156>
References: <44F355EE.3090607@linux.intel.com>
	 <20060830171919.GC18041@instant802.com>
	 <20060921184021.1fb7fa6e@logostar.upir.cz>
	 <4512C4FB.5010704@linux.intel.com>
	 <20060928133824.0cb2aa78@logostar.upir.cz>
	 <452EC34F.2010309@linux.intel.com>
	 <20061018145947.74c1aceb@griffin.suse.cz> <1161176552.5575.17.camel@ux156>
	 <20061018153413.216957b8@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: mabbas <mabbas@linux.intel.com>,
	Jouni Malinen <jkm@devicescape.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:37042 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1161011AbWJRNlX
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Oct 2006 09:41:23 -0400
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20061018153413.216957b8@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-10-18 at 15:34 +0200, Jiri Benc wrote:

> Current WE implementation of rate limiting (SIOCSIWRATE) doesn't make
> much sense with d80211. 

Right.

> Hopefully we'll invent a better solution for
> cfg80211. 

We could do it right here and now then. I haven't understood the matter
though, may I delegate it to you (plural "you" intended here)

> Then we will probably need to put some constraints on
> SIOCSIWRATE emulation (like "rate limiting is lost when you are
> disassociated") - hence the comment.

That's ok.

johannes
