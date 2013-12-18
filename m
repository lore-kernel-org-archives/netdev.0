From: Rasesh Mody <rmody@brocade.com>
Subject: RE: [net-next 07/12] bna: CQ Read Fix
Date: Tue, 17 Dec 2013 17:07:23 -0800
Message-ID: <E5313AF6F2BFD14293E5FD0F94750F86B69010E2D8@HQ1-EXCH01.corp.brocade.com>
References: <1386899678-18591-1-git-send-email-rmody@brocade.com>
	<1386899678-18591-8-git-send-email-rmody@brocade.com>
 <20131214.015538.1434478935532675070.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Adapter Linux Open SRC Team"
	<adapter_linux_open_src_team@Brocade.COM>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:37234 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751938Ab3LRBH1 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Dec 2013 20:07:27 -0500
Received: from pps.filterd (m0000700 [127.0.0.1])
	by mx0b-000f0801.pphosted.com (8.14.5/8.14.5) with SMTP id rBI0lE9W008330
	for <netdev@vger.kernel.org>; Tue, 17 Dec 2013 17:07:26 -0800
Received: from hq1wp-exchub01.corp.brocade.com ([144.49.131.13])
	by mx0b-000f0801.pphosted.com with ESMTP id 1gtuj2rdhm-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 17 Dec 2013 17:07:26 -0800
In-Reply-To: <20131214.015538.1434478935532675070.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From: David Miller [mailto:davem@davemloft.net]
>Sent: Friday, December 13, 2013 10:56 PM
>
>From: Rasesh Mody <rmody@brocade.com>
>Date: Thu, 12 Dec 2013 17:54:33 -0800
>
>> Valid bit check for completion needs read fence, so that it does not
>> get reordered with other loads.
>>
>> Signed-off-by: Rasesh Mody <rmody@brocade.com>
>
>All memory barriers added to code should have a big, verbose, comment
>above it explaining exactly what the requirements are that will be satisfied by
>the memory barrier.
>
>Ie. what memory operation must be visible before or after what other
>memory operation, and why?

Resending the patch set with comment included.
Thanks,
--Rasesh
