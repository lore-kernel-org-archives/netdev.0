From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [RFC] Alternative hidden netwirk device interface
Date: Wed, 31 Jan 2007 19:26:47 +0100
Message-ID: <20070131192647.42d87c10@griffin.suse.cz>
References: <20070129184707.885764375.midnight@suse.cz>
	<20070129102814.6385ad2d@freekitty>
	<20070129140958.0cf6880f@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	David Miller <davem@davemloft.net>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:37983 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1030502AbXAaS04 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jan 2007 13:26:56 -0500
In-Reply-To: <20070129140958.0cf6880f@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 29 Jan 2007 14:09:58 -0800, Stephen Hemminger wrote:
> Change to allow register_netdevice() to be called with a blank name.
> If name is blank, it is not put in name hash list, and doesn't
> show up in /sys or /proc

What about things like neigh_sysctl_register which expects nonempty dev
name or rtnetlink_event which sends a RTM_NEWLINK event (I doubt that
listeners are prepared for nonempty dev name)?

Also, if the interface has ifindex assigned it is accessible from user
space (although it's unlikely anybody would call anything on it) - what
should be the correct result of e.g. SIOCGIFNAME?

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
