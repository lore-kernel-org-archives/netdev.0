From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next] ipv6: use lwtunnel_output6() only if flag
 redirect is set
Date: Fri, 24 Jul 2015 12:42:24 +0200
Message-ID: <20150724104224.GC15706@pox.localdomain>
References: <1437728381-4603-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:35001 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751181AbbGXKm1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2015 06:42:27 -0400
Received: by wibxm9 with SMTP id xm9so22968221wib.0
        for <netdev@vger.kernel.org>; Fri, 24 Jul 2015 03:42:26 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1437728381-4603-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/24/15 at 10:59am, Nicolas Dichtel wrote:
> This function make sense only when LWTUNNEL_STATE_OUTPUT_REDIRECT is set.
> The check is already done in IPv4.
> 
> CC: Thomas Graf <tgraf@suug.ch>
> CC: Roopa Prabhu <roopa@cumulusnetworks.com>
> Fixes: 74a0f2fe8ed5 ("ipv6: rt6_info output redirect to tunnel output")
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Acked-by: Thomas Graf <tgraf@suug.ch>
