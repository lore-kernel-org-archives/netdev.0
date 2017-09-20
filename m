From: "Kalderon, Michal" <Michal.Kalderon@cavium.com>
Subject: Re: [PATCH net-next 3/4] qed: Fix maximum number of CQs for iWARP
Date: Wed, 20 Sep 2017 05:46:35 +0000
Message-ID: <CY1PR0701MB2012B07A2FCD08D598CCFEDB88610@CY1PR0701MB2012.namprd07.prod.outlook.com>
References: <1505841979-26365-1-git-send-email-Michal.Kalderon@cavium.com>
 <1505841979-26365-4-git-send-email-Michal.Kalderon@cavium.com>,<20170919174610.GK5788@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "dledford@redhat.com" <dledford@redhat.com>,
        "Elior, Ariel" <Ariel.Elior@cavium.com>
To: Leon Romanovsky <leon@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0073.outbound.protection.outlook.com ([104.47.32.73]:9896
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751000AbdITFqi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 20 Sep 2017 01:46:38 -0400
In-Reply-To: <20170919174610.GK5788@mtr-leonro.local>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Leon Romanovsky <leon@kernel.org>
Sent: Tuesday, September 19, 2017 8:46 PM
On Tue, Sep 19, 2017 at 08:26:18PM +0300, Michal Kalderon wrote:
>> The maximum number of CQs supported is bound to the number
>> of connections supported, which differs between RoCE and iWARP.
>>
>> This fixes a crash that occurred in iWARP when running 1000 sessions
>> using perftest.
>>
>> Signed-off-by: Michal Kalderon <Michal.Kalderon@cavium.com>
>> Signed-off-by: Ariel Elior <Ariel.Elior@cavium.com>
>> ---
>
>It is worth to add Fixes line.
>
>Thanks
The original code was there before we had iWARP support, so this doesn't
exactly fix an older commit, but fixes iWARP code in general.
