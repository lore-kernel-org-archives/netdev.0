From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH bluetooth-next v3] ieee802154: fix netns settings
Date: Thu, 12 Feb 2015 12:34:06 -0800
Message-ID: <E06E47B0-6A64-4B27-9D9F-D34FEB4DBF88@holtmann.org>
References: <1DEA1346-A348-434E-90F3-80E9EDC7E181@holtmann.org> <1423156890-13382-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2070.6\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Alexander Aring <alex.aring@gmail.com>,
	Network Development <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:46491 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751097AbbBLUe5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2015 15:34:57 -0500
In-Reply-To: <1423156890-13382-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Nicolas,

> 6LoWPAN currently doesn't supports x-netns and works only in init_net.
> 
> With this patch, we ensure that:
> - the wpan interface cannot be moved to another netns;
> - the 6lowpan interface cannot be moved to another netns;
> - the wpan interface is in the same netns than the 6lowpan interface;
> - the 6lowpan interface is in init_net.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Acked-by: Alexander Aring <alex.aring@gmail.com>
> ---
> 
> Note: only compile tested.
> 
> v3: rebase on head of bluetooth-next
>    add the Acked-by line
> 
> v2: update patch title
>    rebase the patch on bluetooth-next
>    update flag features in cfg802154_netdev_notifier_call
> 
> net/ieee802154/6lowpan/core.c | 6 ++++--
> net/ieee802154/core.c         | 1 +
> 2 files changed, 5 insertions(+), 2 deletions(-)

patch has been applied bluetooth-next tree.

Regards

Marcel
