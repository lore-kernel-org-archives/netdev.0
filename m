From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [patch] mpls: small cleanup in inet/inet6_fib_lookup_dev()
Date: Tue, 4 Aug 2015 14:53:02 +0100
Message-ID: <55C0C3BE.8010007@brocade.com>
References: <20150804074422.GB10867@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Tom Herbert <tom@herbertland.com>, <netdev@vger.kernel.org>,
	<kernel-janitors@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:51637 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933627AbbHDNxT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2015 09:53:19 -0400
In-Reply-To: <20150804074422.GB10867@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/08/15 08:44, Dan Carpenter wrote:
> We recently changed this code from returning NULL to returning ERR_PTR.
> There are some left over NULL assignments which we can remove.  We can
> preserve the error code from ip_route_output() instead of always
> returning -ENODEV.  Also these functions use a mix of gotos and direct
> returns.  There is no cleanup necessary so I changed the gotos to
> direct returns.
>
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Acked-by: Robert Shearman <rshearma@brocade.com>
