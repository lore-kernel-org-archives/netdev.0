From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Loop detected  - calling function from different modules
Date: Thu, 31 Aug 2006 09:17:56 +0200
Message-ID: <1157008676.3065.10.camel@ux156>
References: <BAY101-F5AD1ED322334DFDAC9F22AB3E0@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:64954 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1750838AbWHaHRV
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Aug 2006 03:17:21 -0400
To: Frank Schneider <twodipu@hotmail.com>
In-Reply-To: <BAY101-F5AD1ED322334DFDAC9F22AB3E0@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-08-30 at 22:58 +0200, Frank Schneider wrote:

> and i need to do same in reverse way, i.e. call a function from wlan module 
> that is implemented in ath_pci module.

No, you don't. Period. Either wlan provides services to ath_pci, or they
should be one module. Besides, why don't you port atheros drivers to
d80211 instead? And how about showing code? :)

johannes
