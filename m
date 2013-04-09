From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 4/7] xen-netfront: frags -> slots in log message
Date: Tue, 09 Apr 2013 17:35:09 +0400
Message-ID: <5164190D.70905@cogentembedded.com>
References: <1365505655-8021-1-git-send-email-wei.liu2@citrix.com> <1365505655-8021-5-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xen.org,
	ian.campbell@citrix.com, david.vrabel@citrix.com,
	konrad.wilk@oracle.com, annie.li@oracle.com, wdauchy@gmail.com
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:47838 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935140Ab3DINgM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Apr 2013 09:36:12 -0400
Received: by mail-lb0-f171.google.com with SMTP id v10so6863359lbd.30
        for <netdev@vger.kernel.org>; Tue, 09 Apr 2013 06:36:11 -0700 (PDT)
In-Reply-To: <1365505655-8021-5-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 09-04-2013 15:07, Wei Liu wrote:

> Also fix a typo in comment.

> Signed-off-by: Wei Liu <wei.liu2@citrix.com>
> ---
>   drivers/net/xen-netfront.c |    4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)

> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
> index d9097a7..1bb2e20 100644
> --- a/drivers/net/xen-netfront.c
> +++ b/drivers/net/xen-netfront.c
[...]
> @@ -771,7 +771,7 @@ next:
>
>   	if (unlikely(slots > max)) {
>   		if (net_ratelimit())
> -			dev_warn(dev, "Too many frags\n");
> +			dev_warn(dev, "Too many slots\n");

    Shouldn't you have done this change as a part of patch #2?

WBR, Sergei
