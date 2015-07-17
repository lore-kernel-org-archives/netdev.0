From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2 1/5] net: don't reforward packets already
 forwarded by offload device
Date: Thu, 16 Jul 2015 20:32:14 -0700
Message-ID: <55A8773E.2020607@cumulusnetworks.com>
References: <1437033897-8050-1-git-send-email-sfeldma@gmail.com> <1437033897-8050-2-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us,
	simon.horman@netronome.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:35499 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753392AbbGQDcR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2015 23:32:17 -0400
Received: by pactm7 with SMTP id tm7so53612016pac.2
        for <netdev@vger.kernel.org>; Thu, 16 Jul 2015 20:32:16 -0700 (PDT)
In-Reply-To: <1437033897-8050-2-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/16/15, 1:04 AM, sfeldma@gmail.com wrote:
> From: Scott Feldman <sfeldma@gmail.com>
>
> Just before queuing skb for xmit on port, check if skb has been marked by
> switchdev port driver as already fordwarded by device.  If so, drop skb.  A
> non-zero skb->offload_fwd_mark field is set by the switchdev port
> driver/device on ingress to indicate the skb has already been forwarded by
> the device to egress ports with matching dev->skb_mark.  The switchdev port
> driver would assign a non-zero dev->skb_mark for each device port netdev
typo: dev->offload_fwd_mark
> during registration, for example.
>
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>
Acked-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Thanks scott!
