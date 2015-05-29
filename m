From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: qlcnic: clean up sysfs error codes
Date: Thu, 28 May 2015 20:14:12 -0700 (PDT)
Message-ID: <20150528.201412.1123479677671870378.davem@davemloft.net>
References: <1432601385-24582-1-git-send-email-vz@mleia.com>
	<20150528.162844.418918111650211346.davem@davemloft.net>
	<5567BD4A.6030100@mleia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shahed.shaikh@qlogic.com, Dept-GELinuxNICDev@qlogic.com,
	netdev@vger.kernel.org, rajesh.borundia@qlogic.com
To: vz@mleia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52677 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753342AbbE2DOQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 23:14:16 -0400
In-Reply-To: <5567BD4A.6030100@mleia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladimir Zapolskiy <vz@mleia.com>
Date: Fri, 29 May 2015 04:13:46 +0300

> Hello David,
> 
> On 29.05.2015 02:28, David Miller wrote:
>> From: Vladimir Zapolskiy <vz@mleia.com>
>> Date: Tue, 26 May 2015 03:49:45 +0300
>> 
>>> Replace confusing QL_STATUS_INVALID_PARAM == -1 == -EPERM with -EINVAL
>>> and QLC_STATUS_UNSUPPORTED_CMD == -2 == -ENOENT with -EOPNOTSUPP, the
>>> latter error code is arguable, but it is already used in the driver,
>>> so let it be here as well.
>>>
>>> Also remove always false (!buf) check on read(), the driver should
>>> not care if userspace gets its EFAULT or not.
>>>
>>> Signed-off-by: Vladimir Zapolskiy <vz@mleia.com>
>> 
>> Qlogic folks, I'm waiting for your promised feedback.
>> 
> 
> Rajesh reviewed and acked the change, thank you.
> 
> http://www.spinics.net/lists/netdev/msg331073.html

Thanks, I missed that, applied.
