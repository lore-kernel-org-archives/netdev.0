From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC PATCH v2 net-next 2/2] bridge: remove NETIF_F_NETNS_LOCAL from bridge device features.
Date: Mon, 07 Jan 2013 01:20:44 -0800
Message-ID: <877gnp73ir.fsf@xmission.com>
References: <1357543176-15352-1-git-send-email-ramirose@gmail.com>
	<1357543176-15352-3-git-send-email-ramirose@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, netdev@vger.kernel.org, shemminger@vyatta.com
To: Rami Rosen <ramirose@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:39983 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753723Ab3AGJUw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2013 04:20:52 -0500
In-Reply-To: <1357543176-15352-3-git-send-email-ramirose@gmail.com> (Rami
	Rosen's message of "Mon, 7 Jan 2013 09:19:36 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rami Rosen <ramirose@gmail.com> writes:

> There is no need for NETIF_F_NETNS_LOCAL for bridge device; this patch
> removes it.

At the very least add_del_if assumes are network devices are in the same
network namespace as the bridge.  So removing NETIF_F_NETNS_LOCAL is not
safe.


Eric
