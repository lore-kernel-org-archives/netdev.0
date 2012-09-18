From: David Miller <davem@davemloft.net>
Subject: Re: [net] e1000: Small packets may get corrupted during padding by
 HW
Date: Tue, 18 Sep 2012 16:33:08 -0400 (EDT)
Message-ID: <20120918.163308.215275433099722029.davem@davemloft.net>
References: <1347740217-10257-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tushar.n.dave@intel.com, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46894 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755051Ab2IRUdK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2012 16:33:10 -0400
In-Reply-To: <1347740217-10257-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sat, 15 Sep 2012 13:16:57 -0700

> From: Tushar Dave <tushar.n.dave@intel.com>
> 
> On PCI/PCI-X HW, if packet size is less than ETH_ZLEN,
> packets may get corrupted during padding by HW.
> To WA this issue, pad all small packets manually.
> 
> Signed-off-by: Tushar Dave <tushar.n.dave@intel.com>
> Tested-by: Aaron Brown <aaron.f.brown@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

There has been a lot of bike shedding on this patch, but the fix is
correct and thus I'm going to apply it to 'net'.

Thanks.
