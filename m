From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: 802.11/crypto questions
Date: Tue, 08 Aug 2006 13:35:22 +0200
Message-ID: <44D876FA.5080605@sipsolutions.net>
References: <1154410852.17333.4.camel@johannes.berg> <20060807172946.GI4702@instant802.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:8667 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S964810AbWHHLgg
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 07:36:36 -0400
To: Jouni Malinen <jkm@devicescape.com>
In-Reply-To: <20060807172946.GI4702@instant802.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jouni Malinen wrote:
> Depends on what exactly you mean with "on the fly". We have indeed
> changed between doing software and hardware crypto for some cases, e.g.,
> when enabling another BSS while one BSS is using static WEP (which would
> need default WEP keys in hwaccel) in one BSS, we may disable hwaccel for
> the receive case. 
Yeah, that's basically what I was thinking of.

Also, if we add a monitor if, does it disable hw crypto so we can see 
the undecrypted frames?

johannes
