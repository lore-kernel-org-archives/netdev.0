From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/5] Mark the setup_net as __net_init
Date: Thu, 01 Nov 2007 00:46:16 -0700 (PDT)
Message-ID: <20071101.004616.109553457.davem@davemloft.net>
References: <4728D54F.2080208@openvz.org>
	<4728D822.30906@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50147
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754599AbXKAHqR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2007 03:46:17 -0400
In-Reply-To: <4728D822.30906@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Wed, 31 Oct 2007 22:31:46 +0300

> The setup_net is called for the init net namespace
> only (int the CONFIG_NET_NS=n of course) from the __init
> function, so mark it as __net_init to disappear with the
> caller after the boot.
> 
> Yet again, in the perfect world this has to be under
> #ifdef CONFIG_NET_NS, but it isn't guaranteed that every
> subsystem is registered *after* the init_net_ns is set
> up. After we are sure, that we don't start registering
> them before the init net setup, we'll be able to move
> this code under the ifdef.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
