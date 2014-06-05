From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ipconfig: allow IP-Config over DSA
 devices
Date: Thu, 05 Jun 2014 00:01:32 -0700 (PDT)
Message-ID: <20140605.000132.501712848318656492.davem@davemloft.net>
References: <1401473326-21828-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, buytenh@wantstofly.org, jiri@resnulli.us
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40991 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750722AbaFEHBd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2014 03:01:33 -0400
In-Reply-To: <1401473326-21828-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Fri, 30 May 2014 11:08:45 -0700

> Let me know your thoughts. If you feel like something like:
> netdev_is_upper_dev() or something like that is better.

I'm not happy with this change for several reasons.

First, I don't like the idea that ipconfig works for some stacked
devices and not for others.  I'd rather that we simply accept that
direct devices are the only thing supported.

Secondly, the logic in that ipconfig loop is so confusing.  I can't
even figure out what that dsa pointer test is trying to really
accomplish in the second hunk of your patch.

I'd like to defer this for now, sorry.
