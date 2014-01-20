From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tun: handle copy failure in tun_put_user()
Date: Sun, 19 Jan 2014 19:48:56 -0800 (PST)
Message-ID: <20140119.194856.491294439635992592.davem@davemloft.net>
References: <1390187808-5462-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	mst@redhat.com
To: jasowang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41008 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752166AbaATDs7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jan 2014 22:48:59 -0500
In-Reply-To: <1390187808-5462-1-git-send-email-jasowang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jason Wang <jasowang@redhat.com>
Date: Mon, 20 Jan 2014 11:16:48 +0800

> This patch return the error code of copy helpers in tun_put_user() instead of
> ignoring them.
> 
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

If you perform some of the copy successfully, you have to report that
length rather than just an error.

Otherwise userland has no way to determine how much of the data was
successfully sourced.

I'm not applying this, sorry.
