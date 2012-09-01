From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/12] qlcnic: patches for new adapter - Qlogic
 83XX CNA
Date: Fri, 31 Aug 2012 20:53:08 -0400 (EDT)
Message-ID: <20120831.205308.538476490984218378.davem@davemloft.net>
References: <1346452619-2129-1-git-send-email-sony.chacko@qlogic.com>
	<20120831.200035.576516635394055754.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com
To: sony.chacko@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54963 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755319Ab2IAAxJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2012 20:53:09 -0400
In-Reply-To: <20120831.200035.576516635394055754.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Fri, 31 Aug 2012 20:00:35 -0400 (EDT)

> From: Sony Chacko <sony.chacko@qlogic.com>
> Date: Fri, 31 Aug 2012 18:36:47 -0400
> 
>> Please apply the updated patch series to net-next.
> 
> You posted too soon, you received other feedback in the
> mean-time which you should address as well.

Also in patch #5:

-		qlcnic_config_ipaddr(adapter, ifa->ifa_address, QLCNIC_IP_UP);
+		qlcnic_config_ipaddr(adapter, ifa->ifa_address,
+						 QLCNIC_IP_UP);

This is not the correct way to format multi-line function
calls, the correct way is:

		qlcnic_config_ipaddr(adapter, ifa->ifa_address,
				     QLCNIC_IP_UP);

That is, you line up the first character of the argument to
the column right after the openning parenthesis on the pevious
line, using the appropriate number of TAB and SPACE characters
necessary to achieve that.
