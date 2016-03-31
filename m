From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] rds: rds-stress show all zeros after few minutes
Date: Thu, 31 Mar 2016 16:13:35 +0300
Message-ID: <56FD227F.502@cogentembedded.com>
References: <1459385402-28449-1-git-send-email-shamir.rabinovitch@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: shamir rabinovitch <shamir.rabinovitch@oracle.com>,
	rds-devel@oss.oracle.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f43.google.com ([209.85.215.43]:34265 "EHLO
	mail-lf0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752017AbcCaNNj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 09:13:39 -0400
Received: by mail-lf0-f43.google.com with SMTP id c62so59284785lfc.1
        for <netdev@vger.kernel.org>; Thu, 31 Mar 2016 06:13:38 -0700 (PDT)
In-Reply-To: <1459385402-28449-1-git-send-email-shamir.rabinovitch@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 3/31/2016 3:50 AM, shamir rabinovitch wrote:

> Issue can be seen on platforms that use 8K and above page size
> while rds fragment size is 4K. On those platforms single page is
> shared between 2 or more rds fragments. Each fragment has it's own

    Its.

> offeset and rds cong map code need to take this offset to account.

    Offset. What is "cong", congestion?

> Not taking this offset to account lead to reading the data fragment
> as congestion map fragment and hang of the rds transmit due to far
> cong map corruption.
>
> Reviewed-by: Wengang Wang <wen.gang.wang@oracle.com>
> Reviewed-by: Ajaykumar Hotchandani <ajaykumar.hotchandani@oracle.com>
> Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
> Tested-by: Anand Bibhuti <anand.bibhuti@oracle.com>

    These should be after your sign-off, not before.

> Signed-off-by: shamir rabinovitch <shamir.rabinovitch@oracle.com>
[...]

MBR, Sergei
