From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net-next 0/2] net: mpls: multipath route cleanups
Date: Mon, 27 Mar 2017 11:17:27 +0100
Message-ID: <cb25f659-6181-8777-e93f-dd14c6ef2101@brocade.com>
References: <1490394117-19268-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <roopa@cumulusnetworks.com>
To: David Ahern <dsa@cumulusnetworks.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:60194 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752195AbdC0KSe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 06:18:34 -0400
In-Reply-To: <1490394117-19268-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24/03/17 22:21, David Ahern wrote:
> When a device associated with a nexthop is deleted, the nexthop in
> the route is effectively removed, so remove it from the route dump.
>
> Further, when all nexhops have been deleted the route is effectively
> done, so remove the route.
>
> David Ahern (2):
>   mpls: Don't show nexthop if device has been deleted
>   mpls: Delete route when all nexthops have been deleted
>
>  net/mpls/af_mpls.c | 17 +++++++++++++----
>  1 file changed, 13 insertions(+), 4 deletions(-)
>

Acked-by: Robert Shearman <rshearma@brocade.com>
