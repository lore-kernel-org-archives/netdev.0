From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 31/36] net: ieee802154: convert class code to use
 dev_groups
Date: Fri, 26 Jul 2013 15:40:21 -0700 (PDT)
Message-ID: <20130726.154021.878367099404960400.davem@davemloft.net>
References: <1374703539-9705-1-git-send-email-gregkh@linuxfoundation.org>
	<1374703539-9705-32-git-send-email-gregkh@linuxfoundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, alex.bluesman.smirnov@gmail.com,
	dbaryshkov@gmail.com, netdev@vger.kernel.org
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38673 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756108Ab3GZWkW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jul 2013 18:40:22 -0400
In-Reply-To: <1374703539-9705-32-git-send-email-gregkh@linuxfoundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Wed, 24 Jul 2013 15:05:34 -0700

> The dev_attrs field of struct class is going away soon, dev_groups
> should be used instead.  This converts the ieee802154 class code to use
> the correct field.
> 
> Cc: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
> Cc: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> ---
> 
> netdev@ maintainers, feel free to take this through your tree, or ACK it
> and I can take it through mine.

You can take it directly I don't anticipate any conflicts:

Acked-by: David S. Miller <davem@davemloft.net>
