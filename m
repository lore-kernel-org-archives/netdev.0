From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: network manager confused with bcm43xx-d80211?
Date: Mon, 14 Aug 2006 14:28:59 +0200
Message-ID: <44E06C8B.1040400@sipsolutions.net>
References: <44E02F41.2060300@sipsolutions.net>	 <44E031D2.8070106@sipsolutions.net> <1155556011.2885.3.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mbuesch@freenet.de>, netdev@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:48815 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1752028AbWHNM3V
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Aug 2006 08:29:21 -0400
To: Dan Williams <dcbw@redhat.com>
In-Reply-To: <1155556011.2885.3.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dan Williams wrote:
> No, it asks HAL what the device type is actually.  HAL looks for the
> interface in /proc/net/wireless currently, and if it's not there, says
> the device is wired.  Run 'lshal', look for your wlan device, and see if
> info.capabilities includes 'net.80211'.
>   
Yeah, I noticed it wasn't in /proc/net/wireless. Should've tipped me off 
I guess. And I probably also should've thought that nm would ask HAL. 
Looks like I wasn't really on track when I wrote this yesterday ;)
> So if the wlanX interface isn't in /proc/net/wireless, you lose.  I
> think we discussed this in the private rt2x00 thread about a month ago?
> Some patches came out of that one, specifically the SET_NETDEV_DEV ones
> for rt2x00 and d80211.  The problem with d80211 was that it didn't
> implement the get_wireless_stats() handler function, and that function
> (I think?) is the one that lets the wlanX device show up
> in /proc/net/wireless.
>   
Yeah, that sounds about right. Larry, do you remember/know more about 
this? I think you were working in this area?

johannes
