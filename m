From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] Preserve queue mapping with bonding and
 VLAN devices
Date: Fri, 26 Feb 2010 05:50:25 -0800 (PST)
Message-ID: <20100226.055025.30718012.davem@davemloft.net>
References: <33081266938239@webmail48.yandex.ru>
	<1266940741.2109.7.camel@achroite.uk.solarflarecom.com>
	<68631266953760@webmail134.yandex.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org
To: sysoleg@yandex.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59964
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S936265Ab0BZNuH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 08:50:07 -0500
In-Reply-To: <68631266953760@webmail134.yandex.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "\"Oleg A. Arkhangelsky\"" <sysoleg@yandex.ru>
Date: Tue, 23 Feb 2010 22:36:00 +0300

> 23.02.10, 15:59, "Ben Hutchings" <bhutchings@solarflare.com>:
> 
>>  The queue mapping will normally be the same, only no longer biased by 1.
>>  So I think a better solution would be to maintain that bias on TX as
>>  well, or to remove the bias and reserve -1 for unknown RX queue.
> 
> Second try. Not tested but looks OK.
> 
> Must be applied with "[net-next-2.6 PATCH] Multiqueue support for bonding devices"
> 
> Forwarded packet goes through dev_queue_xmit() more that once when using bonding
> or 802.1q VLAN devices, so we've lost rx-tx queue mapping index for real devices.
> This is because initial queue index value (as it recorded by skb_record_tx_queue())
> is overwritten by skb_set_queue_mapping().
> 
> Signed-off-by: Oleg A. Arkhangelsky <sysoleg@yandex.ru> 

Your patches are fine, but they are whitespace corrupted by your
email client (tabs turned into spaces, etc.) so they won't apply
properly.

Please fix this up and resend your patches.

Thanks!
