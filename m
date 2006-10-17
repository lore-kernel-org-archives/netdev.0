From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] d80211: remove unused Super AG definitions, purge
	comment
Date: Tue, 17 Oct 2006 08:59:13 +0200
Message-ID: <1161068354.2735.0.camel@ux156>
References: <20061016183935.GA2488@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:49812 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S932167AbWJQG6V
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Oct 2006 02:58:21 -0400
To: David Kimdon <david.kimdon@devicescape.com>
In-Reply-To: <20061016183935.GA2488@devicescape.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-10-16 at 11:39 -0700, David Kimdon wrote:

> -	MODE_ATHEROS_PRIME = 5 /* Atheros Dynamic Turbo mode */,
> -	MODE_ATHEROS_PRIMEG = 6 /* Atheros Dynamic Turbo mode G */,
>  	NUM_IEEE80211_MODES = 7

You want to adjust that last constant there too, I guess. Why is it an
enum anyway if things are assigned statically?

johannes
