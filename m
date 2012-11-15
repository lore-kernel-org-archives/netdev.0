From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH V2 00/14] Always build GSO/GRO functionality into the
 kernel
Date: Thu, 15 Nov 2012 17:48:33 -0500
Message-ID: <50A57141.1000803@redhat.com>
References: <1353005363-6974-1-git-send-email-vyasevic@redhat.com> <20121115.174205.2002769827912724231.davem@davemloft.net>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57107 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750733Ab2KOWsh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2012 17:48:37 -0500
In-Reply-To: <20121115.174205.2002769827912724231.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/15/2012 05:42 PM, David Miller wrote:
>
> All applied to net-next, but there were some minor conflicts (an
> IS_ENABLED() conversion happened in ip6_output.c in net-next but the
> context in your patch didn't have it) and git warnings (trailing
> whitespace in the final patch).
>
> I fixed them all up, but this is something you can easily take care
> of yourself in the future.
>
> Thanks.
>

sorry,  the patches were bases on net-2.6.  That's probably why you saw 
the conflicts.  I wasn't sure where they should go since they actually 
fix a long standing issue, so I bases them net-2.6.

Sorry, and thanks for fixing things up.
-vlad
