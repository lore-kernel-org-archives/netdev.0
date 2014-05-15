From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2] ipv6: update Destination Cache entries when gateway turn
 into host
Date: Thu, 15 May 2014 14:34:41 -0700
Message-ID: <1400189681.32241.117927421.599F7994@webmail.messagingengine.com>
References: <5374731E.3040608@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Duan Jiong <duanj.fnst@cn.fujitsu.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from new2-smtp.messagingengine.com ([66.111.4.224]:47085 "EHLO
	new2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755717AbaEOVem (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 17:34:42 -0400
In-Reply-To: <5374731E.3040608@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 15, 2014, at 0:56, Duan Jiong wrote:
> 
> RFC 4861 states in 7.2.5:
> 
> 	The IsRouter flag in the cache entry MUST be set based on the
>          Router flag in the received advertisement.  In those cases
>          where the IsRouter flag changes from TRUE to FALSE as a result
>          of this update, the node MUST remove that router from the
>          Default Router List and update the Destination Cache entries
>          for all destinations using that neighbor as a router as
>          specified in Section 7.3.3.  This is needed to detect when a
>          node that is used as a router stops forwarding packets due to
>          being configured as a host.
> 
> Currently, when dealing with NA Message which IsRouter flag changes from
> TRUE to FALSE, the kernel only removes router from the Default Router
> List,
> and don't update the Destination Cache entries.
> 
> Now in order to update those Destination Cache entries, i introduce
> function rt6_clean_tohost().
> 
> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
