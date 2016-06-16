From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: vrf: Switch dst dev to loopback on
 device delete
Date: Wed, 15 Jun 2016 21:40:15 -0700 (PDT)
Message-ID: <20160615.214015.227616106030915305.davem@davemloft.net>
References: <1465929441-19163-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36491 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750928AbcFPEkR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 00:40:17 -0400
In-Reply-To: <1465929441-19163-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Tue, 14 Jun 2016 11:37:21 -0700

> Attempting to delete a VRF device with a socket bound to it can stall:
> 
>   unregister_netdevice: waiting for red to become free. Usage count = 1
> 
> The unregister is waiting for the dst to be released and with it
> references to the vrf device. Similar to dst_ifdown switch the dst
> dev to loopback on delete for all of the dst's for the vrf device
> and release the references to the vrf device.
> 
> Fixes: 193125dbd8eb2 ("net: Introduce VRF device driver")
> Fixes: 35402e3136634 ("net: Add IPv6 support to VRF device")
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied.
