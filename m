From: "Jouni Malinen" <jkm@devicescape.com>
Subject: Re: [PATCH wireless-dev] d80211: Add support for user space client MLME
Date: Thu, 4 May 2006 09:44:23 -0700
Message-ID: <20060504164423.GA12204@instant802.com>
References: <20060503183524.GD10524@instant802.com> <20060504110028.5af3a22a@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, jkmaline@cc.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-40.dex002.intermedia.net ([64.78.21.127]:2676 "EHLO
	dhost002-40.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1030225AbWEDQo1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 May 2006 12:44:27 -0400
To: Jiri Benc <jbenc@suse.cz>
Content-Disposition: inline
In-Reply-To: <20060504110028.5af3a22a@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 04, 2006 at 11:00:28AM +0200, Jiri Benc wrote:

> Ok. So what about PRISM2_HOSTAPD_MGMT_IF ioctl that will add management
> interface (if not added yet) and return its ifindex? It would accept a
> boolean parameter (like PRISM2_PARAM_HOSTAPD) to add/remove that
> interface. If you agree with this, I will make a patch.

Yes, that would be fine.

> Of course, both hostapd and wpa_supplicant needs to be changed for that.
> This should not be a problem now as the d80211 stack is not in a common
> use yet.

Sure, no problems with that at the moment.

> So wpa_supplicant needs to know if the card is softmac or fullmac and
> behave accordingly, right?

Yes. Currently, I'm just using a configuration file parameter for this,
but this information should eventually be exported by the kernel code to
allow wpa_supplicant to select which mode to use without requiring user
configuration.

-- 
Jouni Malinen                                            PGP id EFC895FA
