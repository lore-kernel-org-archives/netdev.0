From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vmxnet3: adjust ring sizes when interface is down
Date: Mon, 16 Jun 2014 21:26:55 -0700 (PDT)
Message-ID: <20140616.212655.977321958825501859.davem@davemloft.net>
References: <1402668201-26628-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sbhatewara@vmware.com,
	pv-drivers@vmware.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51254 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751040AbaFQE06 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2014 00:26:58 -0400
In-Reply-To: <1402668201-26628-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Fri, 13 Jun 2014 10:03:21 -0400

> If ethtool is used to update ring sizes on a vmxnet3 interface that isn't
> running, the change isn't stored, meaning the ring update is effectively is
> ignored and lost without any indication to the user.
> 
> Other network drivers store the ring size update so that ring allocation uses
> the new sizes next time the interface is brought up.  This patch modifies
> vmxnet3 to behave this way as well
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

This is fine, applied, thanks Neil.
