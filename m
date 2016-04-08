From: santosh shilimkar <santosh.shilimkar@oracle.com>
Subject: Re: [PATCH v4 1/2] RDS: memory allocated must be align to 8
Date: Fri, 8 Apr 2016 13:55:17 -0700
Message-ID: <57081AB5.5030703@oracle.com>
References: <1460030256-16791-1-git-send-email-shamir.rabinovitch@oracle.com>
 <57080A27.8050509@oracle.com>
 <20160408.161055.212162741537870508.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shamir.rabinovitch@oracle.com, rds-devel@oss.oracle.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:29816 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754178AbcDHUzZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 16:55:25 -0400
In-Reply-To: <20160408.161055.212162741537870508.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/8/2016 1:10 PM, David Miller wrote:
> From: santosh shilimkar <santosh.shilimkar@oracle.com>
> Date: Fri, 8 Apr 2016 12:44:39 -0700
>
>> On 4/7/2016 4:57 AM, Shamir Rabinovitch wrote:
>>> Fix issue in 'rds_ib_cong_recv' when accessing unaligned memory
>>> allocated by 'rds_page_remainder_alloc' using uint64_t pointer.
>>>
>> Sorry I still didn't follow this change still. What exactly is the
>> problem.
>
> You can't stop the offset at non-8byte intervals, because the chunks
> being used in these arenas can have 64-bit values in it, which must be
> 8-byte aligned.
>
I see. Thanks for explaining it Dave.
Its fine to apply then.
Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>

Regards,
Santosh
