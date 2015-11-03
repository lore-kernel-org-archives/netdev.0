From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net-next v3] mpls: support for dead routes
Date: Tue, 3 Nov 2015 15:15:47 +0000
Message-ID: <5638CFA3.6010605@brocade.com>
References: <1446562191-22416-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Roopa Prabhu <roopa@cumulusnetworks.com>, <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:10351 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751289AbbKCPQL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 10:16:11 -0500
In-Reply-To: <1446562191-22416-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/11/15 14:49, Roopa Prabhu wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> Adds support for RTNH_F_DEAD and RTNH_F_LINKDOWN flags on mpls
> routes due to link events. Also adds code to ignore dead
> routes during route selection
>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> ---
> Dave, I know you are only taking bug fixes currently. This patch
> is borderline a bug fix because Eric thinks it is critical for
> mpls multipath routes. I can sure resubmit it as a bug fix against net
> when it is time if you did prefer that. Thanks!
>
> RFC to v1:
>          Addressed a few comments from Eric and Robert:
>          - remove support for weighted nexthops
>          - Use rt_nhn_alive in the rt structure to keep count of alive
>          routes.
>          What i have not done is: sort nexthops on link events.
>          I am not comfortable recreating or sorting nexthops on
>          every carrier change. This leaves scope for optimizing in the future
>
> v1 to v2:
>          Fix dead nexthop checks as suggested by dave
>
> v2 to v3:
> 	Fix duplicated argument reported by kbuild test robot

FYI, I've sent out comments to v2 and all but one of them also apply to 
this version too.

Thanks,
Rob
