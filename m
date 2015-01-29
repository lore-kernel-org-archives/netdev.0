From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCHv2 net] sunvnet: set queue mapping when doing packet
 copies
Date: Thu, 29 Jan 2015 14:22:56 -0800
Message-ID: <1422570176.21689.38.camel@edumazet-glaptop2.roam.corp.google.com>
References: <54CA8D33.6020006@oracle.com>
	 <1422563996.21689.26.camel@edumazet-glaptop2.roam.corp.google.com>
	 <54CAA7ED.5000100@oracle.com>
	 <1422569982.21689.36.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: David L Stevens <david.stevens@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:40764 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758634AbbA2WW6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 17:22:58 -0500
Received: by mail-ie0-f174.google.com with SMTP id vy18so538517iec.5
        for <netdev@vger.kernel.org>; Thu, 29 Jan 2015 14:22:58 -0800 (PST)
In-Reply-To: <1422569982.21689.36.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-01-29 at 14:19 -0800, Eric Dumazet wrote:

> I guess you can extend the test to sock_wfree and tcp_wfree, but :
> 
> You have to EXPORT_SYMBOL(tcp_wfree)
> 
> Add an #ifdef CONFIG_INET   (take a look at skb_orphan_partial())

Or even better, add a new helper in the same spirit than
skb_orphan_partial() : You would EXPORT_SYMBOL() it and leave
tcp_wfree() as non exported.
