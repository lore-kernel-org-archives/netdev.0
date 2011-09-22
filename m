From: Rasesh Mody <rmody@brocade.com>
Subject: RE: bna: PCI Probe Fix
Date: Wed, 21 Sep 2011 17:32:33 -0700
Message-ID: <E5313AF6F2BFD14293E5FD0F94750F86AC9B6D8FB5@HQ1-EXCH01.corp.brocade.com>
References: <20110920084721.GA8441@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:36509 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750781Ab1IVAcg convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Sep 2011 20:32:36 -0400
Received: from pps.filterd (m0000542 [127.0.0.1])
	by mx0a-000f0801.pphosted.com (8.14.4/8.14.4) with SMTP id p8M0Vvks001866
	for <netdev@vger.kernel.org>; Wed, 21 Sep 2011 17:32:36 -0700
Received: from hq1-exedge.brocade.com (hq1-exedge.brocade.com [144.49.140.11])
	by mx0a-000f0801.pphosted.com with ESMTP id yyr8r02r1-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 21 Sep 2011 17:32:36 -0700
In-Reply-To: <20110920084721.GA8441@elgon.mountain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From: Dan Carpenter [mailto:dan.carpenter@oracle.com]
>Sent: Tuesday, September 20, 2011 1:47 AM
>
>There is a problem introduced in 0caa9aaec5 "bna: PCI Probe Fix".
>
>If register_netdev() fails now, then we call mutex_unlock(&bnad-
>>conf_mutex);
>on the error path, but it's already unlocked.

Thanks Dan!

Sent a fix so that we acquire the lock in error path which will be later unlocked after the cleanup.

Regards,
Rasesh
