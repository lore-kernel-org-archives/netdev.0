From: wenxiong@linux.vnet.ibm.com
Subject: Re: [PATCH V2 2/2] bnx2x: Fix kernel crash and data miscompare
 after EEH recovery
Date: Tue, 03 Jun 2014 15:14:28 -0400
Message-ID: <20140603151428.Horde.DYj0Npir309Tjh6U6PLlFFA@imap.linux.ibm.com>
References: <87B4DDAD5EAFA041BDC28F314593782D0174F4A8@avmb3.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed; DelSp=Yes
Cc: David Miller <davem@davemloft.net>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	netdev <netdev@vger.kernel.org>
To: Dmitry Kravkov <Dmitry.Kravkov@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:42515 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753725AbaFCTOf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jun 2014 15:14:35 -0400
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <wenxiong@linux.vnet.ibm.com>;
	Tue, 3 Jun 2014 15:14:34 -0400
Received: from b01cxnp22036.gho.pok.ibm.com (b01cxnp22036.gho.pok.ibm.com [9.57.198.26])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id F329D38C8059
	for <netdev@vger.kernel.org>; Tue,  3 Jun 2014 15:14:30 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by b01cxnp22036.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s53JEUks7012840
	for <netdev@vger.kernel.org>; Tue, 3 Jun 2014 19:14:30 GMT
Received: from d01av01.pok.ibm.com (localhost [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s53JEUeA032405
	for <netdev@vger.kernel.org>; Tue, 3 Jun 2014 15:14:30 -0400
In-Reply-To: <87B4DDAD5EAFA041BDC28F314593782D0174F4A8@avmb3.qlogic.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Quoting Dmitry Kravkov <Dmitry.Kravkov@qlogic.com>:

> On Jun 2, 2014 5:26 AM, David Miller <davem@davemloft.net> wrote:
>>
>> From: wenxiong@linux.vnet.ibm.com
>> Date: Wed, 28 May 2014 10:56:43 -0500
>>
>> > A rmb() is required to ensure that the CQE is not read before it
>> > is written by the adapter DMA.  PCI ordering rules will make sure
>> > the other fields are written before the marker at the end of struct
>> > eth_fast_path_rx_cqe but without rmb() a weakly ordered processor can
>> > process stale data.
>> >
>> > Without the barrier we have observed various crashes including
>> > bnx2x_tpa_start being called on queues not stopped (resulting in message
>> > start of bin not in stop) and NULL pointer exceptions from bnx2x_rx_int.
>> >
>> > Signed-off-by: Milton Miller <miltonm@bga.com>
> Wen, are you sure the addressee is correct? Our mail server was  
> unable to deliver.
I didn't see the failure when I submitted the patch. I checked with Milton.
  The domain was sold recently.

Thanks,
Wendy

>
> ________________________________
>
> This message and any attached documents contain information from  
> QLogic Corporation or its wholly-owned subsidiaries that may be  
> confidential. If you are not the intended recipient, you may not  
> read, copy, distribute, or use this information. If you have  
> received this transmission in error, please notify the sender  
> immediately by reply e-mail and then delete this message.
