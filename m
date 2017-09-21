From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next ] net: Remove useless function
 skb_header_release
Date: Wed, 20 Sep 2017 21:49:10 -0700
Message-ID: <1505969350.12311.20.camel@perches.com>
References: <1505968771-92232-1-git-send-email-gfree.wind@vip.163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 8bit
To: gfree.wind@vip.163.com, davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0036.hostedemail.com ([216.40.44.36]:53392 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751343AbdIUEtO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 00:49:14 -0400
In-Reply-To: <1505968771-92232-1-git-send-email-gfree.wind@vip.163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-09-21 at 12:39 +0800, gfree.wind@vip.163.com wrote:
> From: Gao Feng <gfree.wind@vip.163.com>
> 
> There is no one which would invokes the function skb_header_release.
> So just remove it now.

This in incomplete.
There are other references to this function.

$ git grep -w skb_header_release
drivers/net/usb/asix_common.c:	 * TCP packets for example are cloned, but skb_header_release()
include/linux/skbuff.h: *	skb_header_release - release reference to header
include/linux/skbuff.h:static inline void skb_header_release(struct sk_buff *skb)
include/linux/skbuff.h: *	Variant of skb_header_release() assuming skb is private to caller.
net/batman-adv/soft-interface.c:	 * data using skb_header_release in our skbs to allow skb_cow_header to
