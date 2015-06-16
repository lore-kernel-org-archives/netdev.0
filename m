From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net] ipv4: include NLM_F_APPEND flag in append route notifications
Date: Tue, 16 Jun 2015 09:14:45 -0700
Message-ID: <55804B75.7050501@cumulusnetworks.com>
References: <1434471120-26742-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:32834 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753147AbbFPQOr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2015 12:14:47 -0400
Received: by padev16 with SMTP id ev16so15645983pad.0
        for <netdev@vger.kernel.org>; Tue, 16 Jun 2015 09:14:47 -0700 (PDT)
In-Reply-To: <1434471120-26742-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/16/15, 9:11 AM, Roopa Prabhu wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> This patch adds NLM_F_APPEND flag to struct nlmsg_hdr->nlmsg_flags
> in newroute notifications if the route add was an append.
> (This is similar to how NLM_F_REPLACE is already part of new
> route replace notifications today)
>
> This helps userspace determine if the route add operation was
> an append.
>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
please ignore, I plan to resend the patch against net-next
