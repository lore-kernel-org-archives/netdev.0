From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vlan: Support sending custom Ethernet CRC.
Date: Mon, 05 Mar 2012 21:14:49 -0500 (EST)
Message-ID: <20120305.211449.2159840360912052625.davem@davemloft.net>
References: <1330999558-14270-1-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58669 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758238Ab2CFCPz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2012 21:15:55 -0500
In-Reply-To: <1330999558-14270-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: greearb@candelatech.com
Date: Mon,  5 Mar 2012 18:05:58 -0800

> NOTE:  You will probably have to disable any
> VLAN hardware assist on the underlying device to get
> this to properly send packets with this feature enabled.

This need to be therefore handled specifically on a device-by-device
basis, and VLAN custom CRC disabled unless the device explicitly
states that it can handle this situation properly and has any
necessary feature rule enforcement codified.
