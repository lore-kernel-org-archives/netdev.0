From: Rasesh Mody <rmody@brocade.com>
Subject: RE: [net-next 06/13] bna: UDP RX Processing Improvements
Date: Tue, 10 Dec 2013 16:05:46 -0800
Message-ID: <E5313AF6F2BFD14293E5FD0F94750F86B69010DB7B@HQ1-EXCH01.corp.brocade.com>
References: <1386481724-32367-1-git-send-email-rmody@brocade.com>
	<1386481724-32367-7-git-send-email-rmody@brocade.com>
 <20131209.191755.1735369355458133155.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Adapter Linux Open SRC Team"
	<adapter_linux_open_src_team@Brocade.COM>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:22167 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751036Ab3LKAFu convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Dec 2013 19:05:50 -0500
Received: from pps.filterd (m0000542 [127.0.0.1])
	by mx0a-000f0801.pphosted.com (8.14.5/8.14.5) with SMTP id rBANMHM3013909
	for <netdev@vger.kernel.org>; Tue, 10 Dec 2013 16:05:49 -0800
Received: from hq1wp-exchub02.corp.brocade.com ([144.49.131.13])
	by mx0a-000f0801.pphosted.com with ESMTP id 1gp3qygj4y-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 10 Dec 2013 16:05:49 -0800
In-Reply-To: <20131209.191755.1735369355458133155.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

>From: David Miller [mailto:davem@davemloft.net]
>Sent: Monday, December 09, 2013 4:18 PM
>
>From: Rasesh Mody <rmody@brocade.com>
>Date: Sat, 7 Dec 2013 21:48:37 -0800
>
>> @@ -233,13 +233,13 @@ struct bnad_tx_unmap {  struct bnad_rx_vector {
>>  	DEFINE_DMA_UNMAP_ADDR(dma_addr);
>>  	u32			len;
>> -};
>> +} __packed;
>
>This is absolutely unacceptable, and at best not even mentioned in your
>commit message.
>
>There is no reason whatsoever to mark this structure as __packed.

By having the bnad_rx_unmap structure marked as __packed we were trying to
reduce the unmap_q size by 16K, __packed would ensure the RX unmap
structure of 40 bytes is packed to 32 bytes. This change was also captured
as a part of the commit message of patch #6 under change details.

We'll address your concern and resubmit the patches.

Thanks,
--Rasesh
