From: Chris Mason <clm@fb.com>
Subject: Re: [PATCH] ipv6: fib: fix fib dump restart
Date: Thu, 24 Apr 2014 16:26:12 -0400
Message-ID: <53597364.2060702@fb.com>
References: <53591645.7010609@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:1223 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752412AbaDXUZ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 16:25:28 -0400
Received: from pps.filterd (m0004003 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id s3OKEpnN019098
	for <netdev@vger.kernel.org>; Thu, 24 Apr 2014 13:25:27 -0700
Received: from mail.thefacebook.com (mailwest.thefacebook.com [173.252.71.148])
	by mx0b-00082601.pphosted.com with ESMTP id 1kesr3tvv2-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 24 Apr 2014 13:25:27 -0700
In-Reply-To: <53591645.7010609@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/24/2014 09:48 AM, Chris Mason wrote:
>
> From: Kumar Sundararajan <kumar@fb.com>
>
> When the ipv6 fib changes during a table dump, the walk is
> restarted and the number of nodes dumped are skipped. But the existing
> code doesn't advance to the next node after a node is skipped. This can
> cause the dump to loop or produce lots of duplicates when the fib
> is modified during the dump.
>
> This change advances the walk to the next node if the current node is
> skipped after a restart.
>

Not sure if patchwork will do the right thing, but adding Kumar's 
signed-off-by:

Signed-off-by: Kumar Sundararajan <kumar@fb.com>

-chris
