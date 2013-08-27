From: Saurabh Mohan <saurabh.mohan@vyatta.com>
Subject: RE: [PATCH net-next] {ipv4,xfrm}: Introduce xfrm_tunnel_notifier
 for xfrm tunnel mode callback
Date: Mon, 26 Aug 2013 18:52:42 -0700
Message-ID: <1902752B0C92F943AB7EA9EE13E2DEEC126DB580C0@HQ1-EXCH02.corp.brocade.com>
References: <1377240424-11758-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Fan Du <fan.du@windriver.com>,
	"steffen.klassert@secunet.com" <steffen.klassert@secunet.com>,
	"herbert@gondor.hengli.com.au" <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:46196 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751391Ab3H0CIS convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Aug 2013 22:08:18 -0400
Received: from pps.filterd (m0000700 [127.0.0.1])
	by mx0b-000f0801.pphosted.com (8.14.5/8.14.5) with SMTP id r7R121NG026622
	for <netdev@vger.kernel.org>; Mon, 26 Aug 2013 18:52:45 -0700
Received: from hq1wp-exchub01.corp.brocade.com ([144.49.131.13])
	by mx0b-000f0801.pphosted.com with ESMTP id 1eg933rf19-4
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 26 Aug 2013 18:52:45 -0700
In-Reply-To: <1377240424-11758-1-git-send-email-fan.du@windriver.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Fan Du [mailto:fan.du@windriver.com]
> Sent: Thursday, August 22, 2013 11:47 PM
> To: steffen.klassert@secunet.com; Saurabh Mohan;
> herbert@gondor.hengli.com.au
> Cc: davem@davemloft.net; netdev@vger.kernel.org
> Subject: [PATCH net-next] {ipv4,xfrm}: Introduce xfrm_tunnel_notifier for
> xfrm tunnel mode callback
> 
> Some thoughts on IPv4 VTI implementation:
> 
> The connection between VTI receiving part and xfrm tunnel mode input
> process is hardly a "xfrm_tunnel", xfrm_tunnel is used in places where, e.g
> ipip/sit and xfrm4_tunnel, acts like a true "tunnel" device.
> 
> In addition, IMHO, VTI doesn't need vti_err to do something meaningful, as
> all VTI needs is just a notifier to be called whenever xfrm_input ingress a
> packet to update statistics.
> 
> So this patch introduce xfrm_tunnel_notifier and meanwhile wipe out
> vti_erri code.
> 
> Signed-off-by: Fan Du <fan.du@windriver.com>
Looks good. Thanks.
Reviewed-by: Saurabh Mohan <saurabh.mohan@vyatta.com>
