From: Albert Lee <albertcc@tw.ibm.com>
Subject: Re: Is the qla3xxx driver in the mainline?
Date: Thu, 27 Jul 2006 11:16:04 +0800
Message-ID: <44C82FF4.4010401@tw.ibm.com>
References: <44C6E546.8030502@tw.ibm.com> <44C75E06.1060402@tls.msk.ru>
Reply-To: albertl@mail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Doug Maxey <dwm@enoyolf.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:51179 "EHLO
	e31.co.us.ibm.com") by vger.kernel.org with ESMTP id S1751250AbWG0DQ0
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jul 2006 23:16:26 -0400
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e31.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k6R3GO47005030
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Wed, 26 Jul 2006 23:16:24 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by westrelay02.boulder.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k6R3GOuj305540
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 26 Jul 2006 21:16:24 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k6R3GNF9015702
	for <netdev@vger.kernel.org>; Wed, 26 Jul 2006 21:16:23 -0600
To: Michael Tokarev <mjt@tls.msk.ru>
In-Reply-To: <44C75E06.1060402@tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Tokarev wrote:
> Albert Lee wrote:
> []
> 
>>(I am curious to have some performance comparison of
>>qla3xxx + open iscsi v.s. qla4xxx + on board TOE/iscsi.)
> 
> 
> On wich card?  I've been told that IPS4010 for example
> isn't supported by qla3xxx.

I've borrowed an ISP4022 based adapter, the qla3xxx
should be supported.

> 
> BTW, I found qla4xxx (on IPS4010) performs noticeable
> worse than open-iscsi stack on top of tigon (non-jumbo-
> frames-capable) GigE NIC (on an eserver xSeries 346
> machine).
> 

Thanks for the info. With qla3xxx, we can actually use
the Ethernet interface of the qla4022 instead of the bcm57xx
tg3. So, we could compare the performance of the on-board
TOE/iscsi with open-iscsi better.

--
albert

