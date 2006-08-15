From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: wlan#ap seems bogus
Date: Tue, 15 Aug 2006 09:22:54 +0200
Message-ID: <44E1764E.8010200@sipsolutions.net>
References: <C86180A8C204554D8A3323D8F6B0A29F0165ACBF@dhost002-46.dex002.intermedia.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jouni Malinen <jkm@devicescape.com>,
	Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:34251 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S965270AbWHOHW6
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 03:22:58 -0400
To: Simon Barber <simon@devicescape.com>
In-Reply-To: <C86180A8C204554D8A3323D8F6B0A29F0165ACBF@dhost002-46.dex002.intermedia.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Simon Barber wrote:
> The purpose of the wlap0ap or wlap0mgmt interface is to communicate
> between hostapd/wpa_supplicant and the kernel. What travels over this
> interface is not quite pure 802.11 management frames - there is some
> meta-data with each frame, and a few special case messages. E.G.
> transmitted frames are returned back to user space to indicate
> successful transmission (required so that the MLME state machine can be
> correctly implemented in user space). I believe these messages form a
> special management protocol between the kernel and user space, and that
> netlink would be the best solution for this link. Switching to netlink
> would allow these bogus 'network' interfaces to be removed alltogether.
> Unfortunately I don't currently have the time to put together a patch to
> do this.
>   
Ok, I'll try to remember that this is waiting on defining a complete new 
netlink API. I was just reading the code and this seemed odd, but I 
agree that no network interface is really needed and hence it can stay 
like this until we switch to a new API unifying it.

Thanks,
johannes
