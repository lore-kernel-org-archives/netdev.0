From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] d80211: get rid of the WME bitfield
Date: Tue, 15 Aug 2006 09:11:02 +0200
Message-ID: <44E17386.70109@sipsolutions.net>
References: <44E02F41.2060300@sipsolutions.net> <44E03112.9070002@sipsolutions.net> <20060814161210.GD1196@instant802.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:21898 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S965269AbWHOHLx
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 03:11:53 -0400
To: Jouni Malinen <jkm@devicescape.com>
In-Reply-To: <20060814161210.GD1196@instant802.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jouni Malinen wrote:
> I think that this is always 16-bit aligned in the current
> implementation, but I would be a bit careful with this type of change
> here. This can be done easily with u8 since the qos_control field has 8
> bits of used data and 8 bits of reserved field. My change was handling
> this as two separate 8-bit values, so no issues with potential unaligned
> accesses.
>   
Good point, I forgot about that. Never mind this patch then, if I get to 
it I'll make a new one.

johannes

