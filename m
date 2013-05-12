From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 1/4] bna: Clear Driver Config Flags When HW Resets
Date: Sat, 11 May 2013 17:38:48 -0700 (PDT)
Message-ID: <20130511.173848.1340042080692595063.davem@davemloft.net>
References: <1368205337-4624-1-git-send-email-rmody@brocade.com>
	<1368205337-4624-2-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, adapter_linux_open_src_team@brocade.com
To: rmody@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60699 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752182Ab3ELAiw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 May 2013 20:38:52 -0400
In-Reply-To: <1368205337-4624-2-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>
Date: Fri, 10 May 2013 10:02:14 -0700

>         Driver configuration flags are retained across open/stop operations
>         preventing configurations to be set in next open/stop.
>         Setting MTU on a 1020 causes network to fail until a reboot is performed
>         on the host.
> 
>         Clear the flags when configuration resets in hardware.

Please stop indenting your commit messages like this, nobody else
does this, so I cannot imagine where you observed this convention.

Resubmit this patch series with this corrected, thanks.
