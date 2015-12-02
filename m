From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net-next v7] mpls: support for dead routes
Date: Wed, 2 Dec 2015 18:23:23 +0000
Message-ID: <565F371B.3010508@brocade.com>
References: <1449037091-12897-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Roopa Prabhu <roopa@cumulusnetworks.com>, <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:34694 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753431AbbLBSXk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 13:23:40 -0500
In-Reply-To: <1449037091-12897-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/12/15 06:18, Roopa Prabhu wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> Adds support for RTNH_F_DEAD and RTNH_F_LINKDOWN flags on mpls
> routes due to link events. Also adds code to ignore dead
> routes during route selection.
>
> Unlike ip routes, mpls routes are not deleted when the route goes
> dead. This is current mpls behaviour and this patch does not change
> that. With this patch however, routes will be marked dead.
> dead routes are not notified to userspace (this is consistent with ipv4
> routes).
>
...

>

Acked-by: Robert Shearman <rshearma@brocade.com>

> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
