From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH 2/7] d80211: add support for SIOCSIWRATE and SIOCGIWRATE
Date: Thu, 21 Sep 2006 18:40:21 +0200
Message-ID: <20060921184021.1fb7fa6e@logostar.upir.cz>
References: <44F355EE.3090607@linux.intel.com>
	<20060830171919.GC18041@instant802.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mabbas <mabbas@linux.intel.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:21414 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1751308AbWIUQkY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2006 12:40:24 -0400
To: "Jouni Malinen" <jkm@devicescape.com>
In-Reply-To: <20060830171919.GC18041@instant802.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 30 Aug 2006 10:19:19 -0700, Jouni Malinen wrote:
> On Mon, Aug 28, 2006 at 01:45:34PM -0700, mabbas wrote:
> 
> > This patch modify d80211 to add SIOCSIWRATE and SIOCGIWRATE
> > commands. this patch almost does the same thing as in 
> > PRISM2_HOSTAPD_SET_RATE_SETS.
> 
> I don't think I would like to get this applied since this seems to be
> changing the design on how the per-STA TX rate limiting is done in a
> way that does not match the original design and no justification has
> been given for that change so far. Some comments below.

I agree with Jouni. We definitely want similar feature but it needs to be
carefully designed (and no, we are not limited by the limitations of WE).
I'm not going to apply the patch.

 Jiri

-- 
Jiri Benc
SUSE Labs
