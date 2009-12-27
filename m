From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix MAC address access in 3c507, ibmlana, pcnet32 and
 libertas
Date: Sat, 26 Dec 2009 20:26:01 -0800 (PST)
Message-ID: <20091226.202601.200357118.davem@davemloft.net>
References: <20091224181125.162AC9D400D@zog.reactivated.net>
	<20091226081635.GA2506@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dsd@laptop.org, netdev@vger.kernel.org, pcnet32@verizon.net,
	dcbw@redhat.com
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58532
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752932AbZL0EZ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Dec 2009 23:25:59 -0500
In-Reply-To: <20091226081635.GA2506@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Sat, 26 Dec 2009 09:16:35 +0100

> Thu, Dec 24, 2009 at 07:11:24PM CET, dsd@laptop.org wrote:
>>Commit f001fde5eadd915f4858d22ed70d7040f48767cf changed
>>net_device.dev_addr from a 32-byte array to a pointer.
>>
>>I found 4 ethernet drivers which rely on sizeof(dev_addr), which are now
>>only copying 4 bytes of the address information on 32bit systems.
>>
>>Fix them to use ETH_ALEN.
>>
>>Signed-off-by: Daniel Drake <dsd@laptop.org>
 ...
> Reviewed-by: Jiri Pirko <jpirko@redhat.com>

Applied, thanks.
