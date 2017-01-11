From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [PATCH net-next 5/6] bnxt_en: Pass RoCE app priority to firmware.
Date: Wed, 11 Jan 2017 09:17:35 -0800
Message-ID: <CACKFLi=6Nt0hr59zA1BpFNH+_q_kU3eR+F6WFOBwFJ03-RzaEg@mail.gmail.com>
References: <1484097159-21575-1-git-send-email-michael.chan@broadcom.com>
 <1484097159-21575-6-git-send-email-michael.chan@broadcom.com> <20170111.104624.1616254027007040020.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>,
        Selvin Xavier <selvin.xavier@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:32773 "EHLO
        mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932347AbdAKRRg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 12:17:36 -0500
Received: by mail-oi0-f50.google.com with SMTP id w204so96657066oiw.0
        for <netdev@vger.kernel.org>; Wed, 11 Jan 2017 09:17:36 -0800 (PST)
In-Reply-To: <20170111.104624.1616254027007040020.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 11, 2017 at 7:46 AM, David Miller <davem@davemloft.net> wrote:
> From: Michael Chan <michael.chan@broadcom.com>
> Date: Tue, 10 Jan 2017 20:12:38 -0500
>
>> diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.h b/drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.h
>> index 35a0d28..f2630cc 100644
>> --- a/drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.h
>> +++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.h
>> @@ -36,6 +36,9 @@ struct bnxt_cos2bw_cfg {
>>
>>  #define HWRM_STRUCT_DATA_SUBTYPE_HOST_OPERATIONAL    0x0300
>>
>> +#define ETH_P_ROCE           0x8915
>
> There's also a similar define in the qedr infiniband driver, this doesn't
> make much sense.
>
> Please add this to if_ether.h, and reference it from there in the drivers.
>
My colleague informed me that he has submitted a patch to do that
through the rdma tree:

http://marc.info/?l=linux-rdma&m=148217575500983&w=2

But it hasn't been merged yet.  I can drop this patch now and wait for
the RDMA patch to show up on net-next. Or I make the change later to
use the common define when the RDMA patch is merged.  Thanks.
