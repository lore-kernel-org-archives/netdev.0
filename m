From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC] [PATCH 0/3] Add Regulatory Domain support to d80211
Date: Tue, 24 Oct 2006 10:25:44 +0200
Message-ID: <1161678344.2840.2.camel@ux156>
References: <43e72e890610231541k2e8e6dcbq98f58a77aa8a52d7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jean Tourrilhes <jt@hpl.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:44943 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S965101AbWJXIYo
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Oct 2006 04:24:44 -0400
To: "Luis R. Rodriguez" <mcgrof@gmail.com>
In-Reply-To: <43e72e890610231541k2e8e6dcbq98f58a77aa8a52d7@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alright, here's more now that I can think clearly again :)

> ISO 3166-1, as part of the ISO 3166 standard, provides codes for the names
> of countries and dependent areas. It was first published in 1974 by
> the International Organization for Standardization (ISO) and defines three
> different codes for each area:
> 
>     * ISO 3166-1 alpha-2, a two-letter system with many applications,
>       most notably the Internet top-level domains (ccTLD) for countries.
>     * ISO 3166-1 alpha-3, a three-letter system.
>     * ISO 3166-1 numeric, a three-digit numerical system, which is
>     identical to that defined by the United Nations Statistical Division.
> 
> Although this would usually be only used in userspace IEEE-802.11d
> has made use of ISO-3166-1 alpha 3. This mapping was added
> to enhance stack support for IEEE-802.11d and 802.11 Regulatory
> Domain control. ieee80211_regdomains makes use of this module
> by creating a map of iso3166 alpha3 country code to stack
> regulatory domain.

But if 802.11d only requires alpha 3, why put all the other stuff into
the kernel as well?

johannes
