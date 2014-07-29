From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next] dcbnl : Fix misleading dcb_app->priority explanation
Date: Mon, 28 Jul 2014 21:03:30 -0700
Message-ID: <53D71D12.30304@gmail.com>
References: <1406606227-22776-1-git-send-email-anish@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Anish Bhatt <anish@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f50.google.com ([209.85.219.50]:41965 "EHLO
	mail-oa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750719AbaG2EDm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2014 00:03:42 -0400
Received: by mail-oa0-f50.google.com with SMTP id g18so9782154oah.23
        for <netdev@vger.kernel.org>; Mon, 28 Jul 2014 21:03:42 -0700 (PDT)
In-Reply-To: <1406606227-22776-1-git-send-email-anish@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/28/2014 08:57 PM, Anish Bhatt wrote:
> Current explanation of dcb_app->priority is wrong. It says priority is
> expected to be a 3-bit unsigned integer which is only true when working with
> DCBx-IEEE. Use of dcb_app->priority by DCBx-CEE expects it to be 802.1p user
> priority bitmap. Updated accordingly
>
> This affects the cxgb4 driver, but I will post those changes as part of a
> larger changeset shortly.
>
> Fixes: 3e29027af4372 ("dcbnl: add support for ieee8021Qaz attributes")
> Signed-off-by: Anish Bhatt <anish@chelsio.com>
> ---

Thanks for catching and fixing this.

Acked-by: John Fastabend <john.r.fastabend@intel.com>

-- 
John Fastabend         Intel Corporation
