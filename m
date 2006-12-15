From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH 1/2] d80211: Turn PHYmode list from an array into a
 linked list
Date: Fri, 15 Dec 2006 14:48:59 +0100
Message-ID: <20061215144859.49a9c8f3@griffin.suse.cz>
References: <200612141920.11439.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, netdev@vger.kernel.org,
	bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:47723 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752136AbWLONs3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Dec 2006 08:48:29 -0500
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200612141920.11439.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 14 Dec 2006 19:20:11 +0100, Michael Buesch wrote:
> This turns the PHY-modes list into a linked list.
> The advantage is that drivers can add modes dynamically, as they probe
> them and don't have to settle to a given arraysize at the beginning
> of probing.

ACK.

> @@ -198,8 +200,7 @@ static int ieee80211_ioctl_scan(struct n
>  		param->u.scan.last_rx = local->scan.rx_packets;
>  		local->scan.rx_packets = -1;
>  	}
> -	param->u.scan.channel = local->hw.modes[local->scan.mode_idx].
> -		channels[local->scan.chan_idx].chan;
> +	param->u.scan.channel = 
> local->scan.mode->channels[local->scan.chan_idx].chan;
>  
>  	return 0;
>  }

The patch is malformed. Fixed and applied to my tree.

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
