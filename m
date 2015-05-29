From: Vladimir Zapolskiy <vz@mleia.com>
Subject: Re: [PATCH] net: qlcnic: clean up sysfs error codes
Date: Fri, 29 May 2015 04:13:46 +0300
Message-ID: <5567BD4A.6030100@mleia.com>
References: <1432601385-24582-1-git-send-email-vz@mleia.com> <20150528.162844.418918111650211346.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: shahed.shaikh@qlogic.com, Dept-GELinuxNICDev@qlogic.com,
	netdev@vger.kernel.org, rajesh.borundia@qlogic.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from li271-223.members.linode.com ([178.79.152.223]:46444 "EHLO
	mail.mleia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753449AbbE2BNt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 May 2015 21:13:49 -0400
In-Reply-To: <20150528.162844.418918111650211346.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

On 29.05.2015 02:28, David Miller wrote:
> From: Vladimir Zapolskiy <vz@mleia.com>
> Date: Tue, 26 May 2015 03:49:45 +0300
> 
>> Replace confusing QL_STATUS_INVALID_PARAM == -1 == -EPERM with -EINVAL
>> and QLC_STATUS_UNSUPPORTED_CMD == -2 == -ENOENT with -EOPNOTSUPP, the
>> latter error code is arguable, but it is already used in the driver,
>> so let it be here as well.
>>
>> Also remove always false (!buf) check on read(), the driver should
>> not care if userspace gets its EFAULT or not.
>>
>> Signed-off-by: Vladimir Zapolskiy <vz@mleia.com>
> 
> Qlogic folks, I'm waiting for your promised feedback.
> 

Rajesh reviewed and acked the change, thank you.

http://www.spinics.net/lists/netdev/msg331073.html

--
With best wishes,
Vladimir
