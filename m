From: David Miller <davem@davemloft.net>
Subject: Re: [net] igbvf: fix divide by zero
Date: Sat, 30 Jun 2012 17:41:05 -0700 (PDT)
Message-ID: <20120630.174105.1534523579965895967.davem@davemloft.net>
References: <1341051799-8824-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mitch.a.williams@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, stable@vger.kernel.org,
	daahern@cisco.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45196 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932069Ab2GAAlG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jun 2012 20:41:06 -0400
In-Reply-To: <1341051799-8824-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sat, 30 Jun 2012 03:23:19 -0700

> From: Mitch A Williams <mitch.a.williams@intel.com>
> 
> Using ethtool -C ethX rx-usecs 0 crashes with a divide by zero.
> Refactor this function to fix this issue and make it more clear
> what the intent of each conditional is. Add comment regarding
> using a setting of zero.
> 
> CC: stable <stable@vger.kernel.org> [3.3+]
> CC: David Ahern <daahern@cisco.com>
> Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
> Tested-by: Aaron Brown <aaron.f.brown@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks.
