From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] ipv6: use lwtunnel_output6() only if flag redirect
 is set
Date: Fri, 24 Jul 2015 06:39:16 -0700
Message-ID: <55B24004.5010805@cumulusnetworks.com>
References: <1437728381-4603-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Thomas Graf <tgraf@suug.ch>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:35866 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753376AbbGXNjT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2015 09:39:19 -0400
Received: by pachj5 with SMTP id hj5so14700124pac.3
        for <netdev@vger.kernel.org>; Fri, 24 Jul 2015 06:39:19 -0700 (PDT)
In-Reply-To: <1437728381-4603-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/24/15, 1:59 AM, Nicolas Dichtel wrote:
> This function make sense only when LWTUNNEL_STATE_OUTPUT_REDIRECT is set.
> The check is already done in IPv4.
>
> CC: Thomas Graf <tgraf@suug.ch>
> CC: Roopa Prabhu <roopa@cumulusnetworks.com>
> Fixes: 74a0f2fe8ed5 ("ipv6: rt6_info output redirect to tunnel output")
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>
Acked-by: Roopa Prabhu <roopa@cumulusnetworks.com>

thanks
