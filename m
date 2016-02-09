From: "Fastabend, John R" <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH 3/7] net: sched: add cls_u32 offload hooks for
 netdevs
Date: Tue, 9 Feb 2016 03:09:44 -0800
Message-ID: <56B9C8F8.8080209@gmail.com>
References: <20160203092708.1356.13733.stgit@john-Precision-Tower-5810>
 <20160203092837.1356.8823.stgit@john-Precision-Tower-5810>
 <20160204131857.GA1458@office.Home>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: ogerlitz@mellanox.com, jiri@resnulli.us, jhs@mojatatu.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	davem@davemloft.net
To: "Amir Vadai\"" <amir@vadai.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f48.google.com ([209.85.218.48]:34810 "EHLO
	mail-oi0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932333AbcBILJ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2016 06:09:56 -0500
Received: by mail-oi0-f48.google.com with SMTP id j125so13093816oih.1
        for <netdev@vger.kernel.org>; Tue, 09 Feb 2016 03:09:56 -0800 (PST)
In-Reply-To: <20160204131857.GA1458@office.Home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/4/2016 5:18 AM, Amir Vadai" wrote:
> On Wed, Feb 03, 2016 at 01:28:37AM -0800, John Fastabend wrote:
>> This patch allows netdev drivers to consume cls_u32 offloads via
>> the ndo_setup_tc ndo op.
>>
>> This works aligns with how network drivers have been doing qdisc
>> offloads for mqprio.
>>
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>> ---

[...]

>> +enum {
>> +	TC_CLSU32_NEW_KNODE,
> TC_CLSU32_NEW_KNODE is never used

aha yep that snuck in there. In a follow up patch for the fm10k devices
where we can support hash tables (e.g. divisor > 1) I use it. Although
on closer inspection I need to check that the divisor == 1 on ixgbe or
else abort because we can get out of sync if software expects hash
tables here.

Thanks, nice catch.

> 
> [...]
> 
