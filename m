From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: [PATCH net] bnx2: fix locking when netconsole is used
Date: Tue, 18 Oct 2016 08:16:55 +0200
Message-ID: <094513d1-4852-cc6d-5ebe-cfc1c37ef7fc@redhat.com>
References: <1476721231-31624-1-git-send-email-ivecera@redhat.com>
 <20161017.132142.526817621160813690.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sony.chacko@qlogic.com,
        Dept-HSGLinuxNICDev@qlogic.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48540 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750813AbcJRGQ7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 18 Oct 2016 02:16:59 -0400
In-Reply-To: <20161017.132142.526817621160813690.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dne 17.10.2016 v 19:21 David Miller napsal(a):
> From: Ivan Vecera <ivecera@redhat.com>
> Date: Mon, 17 Oct 2016 18:20:31 +0200
>
>> diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
>> index 27f11a5..9c408413 100644
>> --- a/drivers/net/ethernet/broadcom/bnx2.c
>> +++ b/drivers/net/ethernet/broadcom/bnx2.c
>> @@ -272,21 +272,24 @@ static u32
>>  bnx2_reg_rd_ind(struct bnx2 *bp, u32 offset)
>>  {
>>  	u32 val;
>> +	unsigned long flags;
>>
>
> Please order local variable declarations from longest to shortest
> line.
Sure Dave, done.

Ivan
