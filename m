From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] net: add NETDEV_PRECHANGEMTU to notify
 before mtu change happens
Date: Thu, 16 Jan 2014 17:16:22 -0800 (PST)
Message-ID: <20140116.171622.986681235335792902.davem@davemloft.net>
References: <1389826939-20691-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us, edumazet@google.com,
	nicolas.dichtel@6wind.com, amwang@redhat.com
To: vfalico@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55712 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751489AbaAQBQX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 20:16:23 -0500
In-Reply-To: <1389826939-20691-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@redhat.com>
Date: Thu, 16 Jan 2014 00:02:18 +0100

> Currently, if a device changes its mtu, first the change happens (invloving
> all the side effects), and after that the NETDEV_CHANGEMTU is sent so that
> other devices can catch up with the new mtu. However, if they return
> NOTIFY_BAD, then the change is reverted and error returned.
> 
> This is a really long and costy operation (sometimes). To fix this, add
> NETDEV_PRECHANGEMTU notification which is called prior to any change
> actually happening, and if any callee returns NOTIFY_BAD - the change is
> aborted. This way we're skipping all the playing with apply/revert the mtu.
> 
> CC: "David S. Miller" <davem@davemloft.net>
> CC: Jiri Pirko <jiri@resnulli.us>
> CC: Eric Dumazet <edumazet@google.com>
> CC: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> CC: Cong Wang <amwang@redhat.com>
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>

Applied.
