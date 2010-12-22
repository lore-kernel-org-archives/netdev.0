From: Rasesh Mody <rmody@brocade.com>
Subject: RE: [PATCH 01/10] bna: TxRx and datapath fix
Date: Wed, 22 Dec 2010 15:44:28 -0800
Message-ID: <E5313AF6F2BFD14293E5FD0F94750F86A5CFD8353C@HQ1-EXCH01.corp.brocade.com>
References: <1293002596-3239-1-git-send-email-rmody@brocade.com>
	<1293002596-3239-2-git-send-email-rmody@brocade.com>
 <20101222.151213.115925760.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Debashis Dutt <ddutt@Brocade.COM>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:38369 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752127Ab0LVXod convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Dec 2010 18:44:33 -0500
In-Reply-To: <20101222.151213.115925760.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David

>From: David Miller [mailto:davem@davemloft.net]
>Sent: Wednesday, December 22, 2010 3:12 PM
>
>From: Rasesh Mody <rmody@brocade.com>
>Date: Tue, 21 Dec 2010 23:23:07 -0800
>
>>  #define bnad_dim_timer_running(_bnad)				\
>>  	(((_bnad)->cfg_flags & BNAD_CF_DIM_ENABLED) && 		\
>>  	(test_bit(BNAD_RF_DIM_TIMER_RUNNING, &((_bnad)->run_flags))))
>>
>> +#if defined(__ia64__)
>> +#define bnad_udelay	udelay
>> +#else
>> +#define bnad_udelay	__udelay
>> +#endif
>> +
>
>What in the world is this?
>
>Something like this should absolutely, positively, never be necessary.

We will send a corrective patch to fix this.

Thanks,
Rasesh Mody
