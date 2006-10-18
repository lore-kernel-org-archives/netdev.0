From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH 2/7] d80211: add support for SIOCSIWRATE and SIOCGIWRATE
Date: Wed, 18 Oct 2006 15:34:13 +0200
Message-ID: <20061018153413.216957b8@griffin.suse.cz>
References: <44F355EE.3090607@linux.intel.com>
	<20060830171919.GC18041@instant802.com>
	<20060921184021.1fb7fa6e@logostar.upir.cz>
	<4512C4FB.5010704@linux.intel.com>
	<20060928133824.0cb2aa78@logostar.upir.cz>
	<452EC34F.2010309@linux.intel.com>
	<20061018145947.74c1aceb@griffin.suse.cz>
	<1161176552.5575.17.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mabbas <mabbas@linux.intel.com>,
	Jouni Malinen <jkm@devicescape.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:64223 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1161000AbWJRNeQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2006 09:34:16 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1161176552.5575.17.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 18 Oct 2006 15:02:32 +0200, Johannes Berg wrote:
> On Wed, 2006-10-18 at 14:59 +0200, Jiri Benc wrote:
> > But we will have to convert d80211 to cfg80211 anyway,
> > so it will depend on the way rate limiting is implemented in cfg80211
> > in the end.
> 
> I'd think it should be more the other way round with d80211/cfg80211
> doing whatever makes most sense...

Current WE implementation of rate limiting (SIOCSIWRATE) doesn't make
much sense with d80211. Hopefully we'll invent a better solution for
cfg80211. Then we will probably need to put some constraints on
SIOCSIWRATE emulation (like "rate limiting is lost when you are
disassociated") - hence the comment.

 Jiri

-- 
Jiri Benc
SUSE Labs
