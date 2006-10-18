From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH 2/7] d80211: add support for SIOCSIWRATE and SIOCGIWRATE
Date: Wed, 18 Oct 2006 14:59:47 +0200
Message-ID: <20061018145947.74c1aceb@griffin.suse.cz>
References: <44F355EE.3090607@linux.intel.com>
	<20060830171919.GC18041@instant802.com>
	<20060921184021.1fb7fa6e@logostar.upir.cz>
	<4512C4FB.5010704@linux.intel.com>
	<20060928133824.0cb2aa78@logostar.upir.cz>
	<452EC34F.2010309@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jouni Malinen <jkm@devicescape.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:14299 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1030229AbWJRM7v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2006 08:59:51 -0400
To: mabbas <mabbas@linux.intel.com>
In-Reply-To: <452EC34F.2010309@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 12 Oct 2006 15:35:59 -0700, mabbas wrote:
> Should I add the new field to sta_info or to ieee80211_sub_if_data. If 
> we added to sta_info then it wont be persistent.
> We will loose SIOCSIWRATE restriction once we associate with new AP. 
> Then in 3
> we bitmask sta->curr_rates with ieee80211_sub_if_data::allowed_rates and 
> this will solve the problem for IBSS as well.

Fine with me. Though I'm not sure that Jouni will agree :-)

On the other hand, as WE are considered obsolete now, it's more
important to have a nice design than to support all WE calls in an
intuitive way. But we will have to convert d80211 to cfg80211 anyway,
so it will depend on the way rate limiting is implemented in cfg80211
in the end.

 Jiri

-- 
Jiri Benc
SUSE Labs
