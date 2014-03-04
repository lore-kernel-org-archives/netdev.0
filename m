From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netpoll: Don't call driver methods from interrupt
 context.
Date: Tue, 04 Mar 2014 16:09:54 -0500 (EST)
Message-ID: <20140304.160954.1026981765209536637.davem@davemloft.net>
References: <874n3fow2i.fsf@xmission.com>
	<CAM_iQpUo7LDcXqKxpZwKjx_KX6R2hVcyHx3GJnYxEg+9Nez0Rg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, netdev@vger.kernel.org, mpm@selenic.com,
	satyam.sharma@gmail.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37009 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932730AbaCDVJ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 16:09:57 -0500
In-Reply-To: <CAM_iQpUo7LDcXqKxpZwKjx_KX6R2hVcyHx3GJnYxEg+9Nez0Rg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Mon, 3 Mar 2014 20:23:03 -0800

> netpoll code needs to rewrite.

People (myself included) have been saying this for a decade, nobody
has come up with a better design that achieves what the current one is
at least able to.
