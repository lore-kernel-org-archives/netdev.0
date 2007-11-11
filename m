From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netns: init dev_base_lock only once
Date: Sat, 10 Nov 2007 22:09:42 -0800 (PST)
Message-ID: <20071110.220942.19699472.davem@davemloft.net>
References: <20071107125133.GA6213@localhost.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org, ebiederm@xmission.com
To: adobriyan@sw.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58081
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752593AbXKKGJm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Nov 2007 01:09:42 -0500
In-Reply-To: <20071107125133.GA6213@localhost.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Dobriyan <adobriyan@sw.ru>
Date: Wed, 7 Nov 2007 15:51:33 +0300

> * it already statically initialized
> * reinitializing live global spinlock every time netns is
>   setup is also wrong
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@sw.ru>

Good catch.

Applied, thanks Alexey.
