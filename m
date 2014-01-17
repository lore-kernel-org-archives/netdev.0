From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] team: block mtu change before it happens
 via NETDEV_PRECHANGEMTU
Date: Thu, 16 Jan 2014 17:16:30 -0800 (PST)
Message-ID: <20140116.171630.1801782887385167816.davem@davemloft.net>
References: <1389826939-20691-1-git-send-email-vfalico@redhat.com>
	<1389826939-20691-2-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us
To: vfalico@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55718 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751489AbaAQBQa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 20:16:30 -0500
In-Reply-To: <1389826939-20691-2-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@redhat.com>
Date: Thu, 16 Jan 2014 00:02:19 +0100

> Now it catches the NETDEV_CHANGEMTU notification, which is signaled after
> the actual change happened on the device, and returns NOTIFY_BAD, so that
> the change on the device is reverted.
> 
> This might be quite costly and messy, so use the new NETDEV_PRECHANGEMTU to
> catch the MTU change before the actual change happens and signal that it's
> forbidden to do it.
> 
> CC: Jiri Pirko <jiri@resnulli.us>
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>

Also applied, nice work.
