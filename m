From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlink: Rename pid to portid to avoid confusion
Date: Mon, 10 Sep 2012 15:31:42 -0400 (EDT)
Message-ID: <20120910.153142.112339451501543835.davem@davemloft.net>
References: <87fw6tjb4p.fsf@xmission.com>
	<20120908095441.359df1d1@s6510.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32831 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758347Ab2IJTbo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2012 15:31:44 -0400
In-Reply-To: <20120908095441.359df1d1@s6510.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Sat, 8 Sep 2012 09:54:41 -0700

> On Fri, 07 Sep 2012 23:12:54 -0700
> ebiederm@xmission.com (Eric W. Biederman) wrote:
> 
>> It is a frequent mistake to confuse the netlink port identifier with a
>> process identifier.  Try to reduce this confusion by renaming fields
>> that hold port identifiers portid instead of pid.
>> 
>> I have carefully avoided changing the structures exported to
>> userspace to avoid changing the userspace API.
>> 
>> I have successfully built an allyesconfig kernel with this change.
>> 
>> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
>> ---
> 
> Ok. I validated that no header file used by iproute2 is affected.
> 
> Acked-by: Stephen Hemminger <shemminger@vyatta.com>

Applied to net-next, thanks.
