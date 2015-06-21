From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Cavium: Bug fix: MAC address setting in shutdown
 state
Date: Sun, 21 Jun 2015 09:57:41 -0700 (PDT)
Message-ID: <20150621.095741.2120952262358582714.davem@davemloft.net>
References: <00a401d0a8d0$271e3760$755aa620$@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Aleksey.Makarov@caviumnetworks.com,
	sgoutham@cavium.com, thlab.kim@samsung.com, s.dyasly@samsung.com
To: p.fedin@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46624 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751775AbbFUQp4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jun 2015 12:45:56 -0400
In-Reply-To: <00a401d0a8d0$271e3760$755aa620$@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Fedin <p.fedin@samsung.com>
Date: Wed, 17 Jun 2015 10:35:14 +0300

> This bug pops up with NetworkManager on Fedora 21. NetworkManager tends to
> stop the interface (nicvf_stop() is called) before changing settings. In
> stopped state MAC cannot be sent to a PF. However, when the interface is
> restarted (nicvf_open() is called), we ping the PF using NIC_MBOX_MSG_READY
> message, and the PF replies back with old MAC address, overriding what we had
> after MAC setting from userspace. As a result, we cannot set MAC address using
> NetworkManager.
> 
> This patch introduces special tracking of MAC change in stopped state so that
> the correct new MAC address is sent to a PF when interface is reopen.
> 
> Signed-off-by: Pavel Fedin <p.fedin@samsung.com>

Your patch was corrupted by your email client, please fix this up and
resubmit.
