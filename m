From: Iyappan Subramanian <isubramanian@apm.com>
Subject: Re: [PATCH v1 4/5] drivers: net: xgene: Add 10GbE support
Date: Wed, 24 Sep 2014 10:24:52 -0700
Message-ID: <CAKh23F=8Y4vGw1LkXbYD_1138nYZ0sCCPRjf0YS5JqjS10JnPQ@mail.gmail.com>
References: <1411530688-2939-1-git-send-email-isubramanian@apm.com>
	<1411530688-2939-5-git-send-email-isubramanian@apm.com>
	<7752137.3u6F6qDtIo@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Keyur Chudgar <kchudgar@apm.com>, patches <patches@apm.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod5og115.obsmtp.com ([64.18.0.246]:55426 "HELO
	exprod5og115.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753465AbaIXRYz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2014 13:24:55 -0400
Received: by mail-lb0-f175.google.com with SMTP id w7so5552664lbi.34
        for <netdev@vger.kernel.org>; Wed, 24 Sep 2014 10:24:52 -0700 (PDT)
In-Reply-To: <7752137.3u6F6qDtIo@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Arnd,

On Wed, Sep 24, 2014 at 6:10 AM, Arnd Bergmann <arnd@arndb.de> wrote:
> On Tuesday 23 September 2014 20:51:27 Iyappan Subramanian wrote:
>> -static void xgene_enet_wr_mcx_mac(struct xgene_enet_pdata *pdata,
>> -                                 u32 wr_addr, u32 wr_data)
>> +void xgene_enet_wr_mac(struct xgene_enet_pdata *pdata, u32 wr_addr, u32 wr_data)
>>  {
>>         void __iomem *addr, *wr, *cmd, *cmd_done;
>>
>> -       addr = pdata->mcx_mac_addr + MAC_ADDR_REG_OFFSET;
>> -       wr = pdata->mcx_mac_addr + MAC_WRITE_REG_OFFSET;
>> -       cmd = pdata->mcx_mac_addr + MAC_COMMAND_REG_OFFSET;
>> -       cmd_done = pdata->mcx_mac_addr + MAC_COMMAND_DONE_REG_OFFSET;
>> +       addr = pdata->mac_addr + MAC_ADDR_REG_OFFSET;
>> +       wr = pdata->mac_addr + MAC_WRITE_REG_OFFSET;
>> +       cmd = pdata->mac_addr + MAC_COMMAND_REG_OFFSET;
>> +       cmd_done = pdata->mac_addr + MAC_COMMAND_DONE_REG_OFFSET;
>>
>>         if (!xgene_enet_wr_indirect(addr, wr, cmd, cmd_done, wr_addr, wr_data))
>>                 netdev_err(pdata->ndev, "MCX mac write failed, addr: %04x\n",
>>                            wr_addr);
>>  }
>>
>> -static void xgene_enet_rd_csr(struct xgene_enet_pdata *pdata,
>> -                             u32 offset, u32 *val)
>> +void xgene_enet_rd_csr(struct xgene_enet_pdata *pdata, u32 offset, u32 *val)
>>  {
>>         void __iomem *addr = pdata->eth_csr_addr + offset;
>>
>>
>
> A lot of the changes in this patch seem to just rename existing interfaces.
> Please split those out into a preparatory patch, to make it easier to
> review the actual functional changes.

Sure.  I will do as you suggest.  Thanks for the review.

>
>         Arnd
> CONFIDENTIALITY NOTICE: This e-mail message, including any attachments,
> is for the sole use of the intended recipient(s) and contains information
> that is confidential and proprietary to Applied Micro Circuits Corporation or its subsidiaries.
> It is to be used solely for the purpose of furthering the parties' business relationship.
> All unauthorized review, use, disclosure or distribution is prohibited.
> If you are not the intended recipient, please contact the sender by reply e-mail
> and destroy all copies of the original message.
>
