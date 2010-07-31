From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bonding: take rtnl in bond_loadbalance_arp_mon
Date: Fri, 30 Jul 2010 23:28:48 -0700 (PDT)
Message-ID: <20100730.232848.115930956.davem@davemloft.net>
References: <29111.1280353189@death>
	<20100729011355.GV7497@gospo.rdu.redhat.com>
	<23558.1280425791@death>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andy@greyhouse.net, netdev@vger.kernel.org
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33811
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755151Ab0GaG2a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jul 2010 02:28:30 -0400
In-Reply-To: <23558.1280425791@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Thu, 29 Jul 2010 10:49:51 -0700

> Andy Gospodarek <andy@greyhouse.net> wrote:
> 
>>[PATCH net-next] bonding: prevent sysfs from allowing arp monitoring with alb/tlb
>>
>>When using module options arp monitoring and balance-alb/balance-tlb
>>are mutually exclusive options.  Anytime balance-alb/balance-tlb are
>>enabled mii monitoring is forced to 100ms if not set.  When configuring
>>via sysfs no checking is currently done.
>>
>>Handling these cases with sysfs has to be done a bit differently because
>>we do not have all configuration information available at once.  This
>>patch will not allow a mode change to balance-alb/balance-tlb if
>>arp_interval is already non-zero.  It will also not allow the user to
>>set a non-zero arp_interval value if the mode is already set to
>>balance-alb/balance-tlb.  They are still mutually exclusive on a
>>first-come, first serve basis.
>>
>>Tested with initscripts on Fedora and manual setting via sysfs.
>>
>>Signed-off-by: Andy Gospodarek <gospo@redhat.com>
> 
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

Applied, thanks guys.
