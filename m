From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [net-next PATCH 1/1] drivers: net: cpsw: add support to show
 hw stats via ethtool get_regs
Date: Sat, 20 Jul 2013 13:30:07 +0530
Message-ID: <51EA4387.9070301@ti.com>
References: <1374242841-17141-1-git-send-email-mugunthanvnm@ti.com> <20130719.173202.1362261343675979678.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-omap@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:37144 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751190Ab3GTIDx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Jul 2013 04:03:53 -0400
In-Reply-To: <20130719.173202.1362261343675979678.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/20/2013 6:02 AM, David Miller wrote:
> From: Mugunthan V N <mugunthanvnm@ti.com>
> Date: Fri, 19 Jul 2013 19:37:21 +0530
>
>> Add support to show CPSW hardware statistics to user via ethtool get_regs
>> ops so user can find if there were any error reported or the system is
>> over loaded duing hagh data rate transfer.
>>
>> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
> This is not the correct way to provide this functionality.  ->get_regs()
> is for dumping the raw hardware registers to userspace for low level
> debugging purposes, not for providing HW specific statistics.
>
> The correct thing to do is provide an appropriate implementation of
> the ->get_strings() and ->get_ethtool_stats() methods.
Will change the implementation and resubmit the patch.

Regards
Mugunthan V N
