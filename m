From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] rds: rds-stress show all zeros after few minutes
Date: Thu, 31 Mar 2016 17:23:30 +0300
Message-ID: <56FD32E2.8050003@cogentembedded.com>
References: <1459385402-28449-1-git-send-email-shamir.rabinovitch@oracle.com>
 <56FD227F.502@cogentembedded.com>
 <20160331142047.GA24193@shamir-linux.uk.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: rds-devel@oss.oracle.com, netdev@vger.kernel.org,
	davem@davemloft.net
To: Shamir Rabinovitch <shamir.rabinovitch@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f181.google.com ([209.85.217.181]:35830 "EHLO
	mail-lb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754376AbcCaOXf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 10:23:35 -0400
Received: by mail-lb0-f181.google.com with SMTP id bc4so53591990lbc.2
        for <netdev@vger.kernel.org>; Thu, 31 Mar 2016 07:23:34 -0700 (PDT)
In-Reply-To: <20160331142047.GA24193@shamir-linux.uk.oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/31/2016 5:20 PM, Shamir Rabinovitch wrote:

>>> Issue can be seen on platforms that use 8K and above page size
>>> while rds fragment size is 4K. On those platforms single page is
>>> shared between 2 or more rds fragments. Each fragment has it's own
>>
>>     Its.
>
> Fixed in next version.
> Thanks.
>
>>
>>> offeset and rds cong map code need to take this offset to account.
>>
>>     Offset. What is "cong", congestion?
>
> 'Offset' is in middle of the sentence so it is OK as-is.

    No, "offeset" is not OK. :-)

[...]

>>> Signed-off-by: shamir rabinovitch <shamir.rabinovitch@oracle.com>
[...]

MBR, Sergei
