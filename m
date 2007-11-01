From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5][NETNS] Make the init/exit hooks checks outside the
 loop
Date: Thu, 01 Nov 2007 00:43:07 -0700 (PDT)
Message-ID: <20071101.004307.129816044.davem@davemloft.net>
References: <4728D54F.2080208@openvz.org>
	<4728D637.5030106@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35431
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754409AbXKAHnI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2007 03:43:08 -0400
In-Reply-To: <4728D637.5030106@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Wed, 31 Oct 2007 22:23:35 +0300

> When the new pernet something (subsys, device or operations) is
> being registered, the init callback is to be called for each
> namespace, that currently exitst in the system. During the
> unregister, the same is to be done with the exit callback.
> 
> However, not every pernet something has both calls, but the
> check for the appropriate pointer to be not NULL is performed
> inside the for_each_net() loop.
> 
> This is (at least) strange, so tune this.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
