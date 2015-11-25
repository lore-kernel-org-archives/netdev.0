From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net-next v5] mpls: support for dead routes
Date: Wed, 25 Nov 2015 09:51:30 +0000
Message-ID: <565584A2.5090809@brocade.com>
References: <1448407342-61181-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Roopa Prabhu <roopa@cumulusnetworks.com>, <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:38254 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751739AbbKYJvp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2015 04:51:45 -0500
In-Reply-To: <1448407342-61181-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24/11/15 23:22, Roopa Prabhu wrote:
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
