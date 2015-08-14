From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net-next 1/3] lwt: Add support to redirect dst.input
Date: Fri, 14 Aug 2015 08:50:00 +0100
Message-ID: <55CD9DA8.3000605@brocade.com>
References: <1439484843-3848061-1-git-send-email-tom@herbertland.com>
 <1439484843-3848061-2-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <tgraf@suug.ch>, <roopa@cumulusnetworks.com>, <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:48634 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751255AbbHNHuS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2015 03:50:18 -0400
In-Reply-To: <1439484843-3848061-2-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13/08/15 17:54, Tom Herbert wrote:
> This patch adds the capability to redirect dst input in the same way
> that dst output is redirected by LWT.
>
> Also, save the original dst.input and and dst.out when setting up
> lwtunnel redirection. These can be called by the client as a pass-
> through.

The lwt state is refcounted so it can be shared by different dst 
contexts, so is it safe to be storing per-dst state in the lwt state?

Otherwise, it looks good.

Thanks,
Rob
