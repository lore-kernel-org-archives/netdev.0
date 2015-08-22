From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v2 net-next] r8169: Add values missing in @get_stats64
 from HW counters
Date: Sat, 22 Aug 2015 13:23:34 +0200
Message-ID: <20150822112334.GB24519@electric-eye.fr.zoreil.com>
References: <1439888664-28620-1-git-send-email-vinschen@redhat.com>
 <1440151756-18165-1-git-send-email-vinschen@redhat.com>
 <20150821193926.GA16437@electric-eye.fr.zoreil.com>
 <20150821220756.GI19683@calimero.vinschen.de>
 <20150821235940.GA20313@electric-eye.fr.zoreil.com>
 <20150822083916.GA17408@calimero.vinschen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, Hayes Wang <hayeswang@realtek.com>,
	Ivan Vecera <ivecera@redhat.com>,
	David Miller <davem@davemloft.net>,
	nic_swsd <nic_swsd@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:55305 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753525AbbHVLYH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Aug 2015 07:24:07 -0400
Content-Disposition: inline
In-Reply-To: <20150822083916.GA17408@calimero.vinschen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Corinna Vinschen <vinschen@redhat.com> :
[...]
> That won't happen with the current patch because only
> rtl8169_reset_counters would print a log message, it's only called from
> open, and open occurs rather seldom.  Atop of that the code only tries
> to reset counters on HW supporting it, and only if resetting on the HW
> fails, there will be a log message at all.  There's no reasonable chance
> that failing to reset the counters will lead to log flooding.

Thanks for reformulating it. We are in violent agreement here.

[...]
> I'm not trying to avoid work, I'm trying to understand.
> 
> As far as I see it failing to reset the counters has no impact on the
> viability of the code.  It's still working with offsets and if the
> offset is 0 or non-0, the user space won't see the difference in the
> values returned by @get_stats64.  Successful resetting the counters is
> just a bonus.

Sorry, my english was really bad:

the code should propagate failure when rtl8169_reset_counters and
rtl8169_update_counters *simultaneously* fail.

-- 
Ueimor
