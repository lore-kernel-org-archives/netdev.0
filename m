From: Logan Gunthorpe <logang@deltatee.com>
Subject: Re: cxgb4 is broken in v4.12-rc1
Date: Mon, 15 May 2017 19:50:13 -0600
Message-ID: <745b4343-52e7-b8c7-0889-98ea843de15b@deltatee.com>
References: <f5966da1-44e7-ebf7-c5df-28f815a77424@deltatee.com>
 <CY4PR12MB1432CA69BD6B7AE335B5DBB2C1E60@CY4PR12MB1432.namprd12.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Stephen Bates <sbates@raithlin.com>,
        SWise OGC <swise@opengridcomputing.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ganesh GR <ganeshgr@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ale.deltatee.com ([207.54.116.67]:33561 "EHLO ale.deltatee.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751529AbdEPBuV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 15 May 2017 21:50:21 -0400
In-Reply-To: <CY4PR12MB1432CA69BD6B7AE335B5DBB2C1E60@CY4PR12MB1432.namprd12.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Thanks for looking into it. The version information of the card is:

[    5.235956] cxgb4 0000:07:00.4: Chelsio T62100-LP-CR rev 0
[    5.235957] cxgb4 0000:07:00.4: S/N: PT51160053, P/N: 11012106004
[    5.235959] cxgb4 0000:07:00.4: Firmware version: 1.16.29.4
[    5.235960] cxgb4 0000:07:00.4: Bootstrap version: 255.255.255.255
[    5.235961] cxgb4 0000:07:00.4: TP Microcode version: 0.1.23.2

Logan


On 15/05/17 07:00 PM, Ganesh GR wrote:
> 
> Hi Logan,
> 
> Thanks for reporting the issue I will try to reproduce this, btw what is the firmware version
> on your setup?.
> 
> Regards
> Ganesh
> 
> 
> 
> 
> From: Logan Gunthorpe <logang@deltatee.com>
> Sent: Tuesday, May 16, 2017 4:06 AM
> To: Ganesh GR
> Cc: David S. Miller; Stephen Bates; SWise OGC; netdev@vger.kernel.org
> Subject: BUG: cxgb4 is broken in v4.12-rc1
>     
> Hi,
> 
> With rc1 my T62100-LP-CR no longer functions correctly. Everything
> appears fine but the link never goes into the UP state. I have one peer
> with an older (functioning) kernel and the other peer on rc1.
> 
> I've bisected to find this is the offending commit:
> 
> 3bb4858fd: cxgb4: avoid disabling FEC by default
> 
> I've also attached a bisect log.
> 
> Let me know if you need anything else.
> 
> Thanks,
> 
> Logan
>     
> 
