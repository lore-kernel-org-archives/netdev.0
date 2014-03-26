From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH 0/2] bridge: Fix forwarding of 8021AD frames
Date: Wed, 26 Mar 2014 12:09:52 -0400
Message-ID: <5332FBD0.2010802@redhat.com>
References: <1395849627-15711-1-git-send-email-vyasevic@redhat.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: bridge@lists.linux-foundation.org, shemminger@vyatta.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34542 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751803AbaCZQJ4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2014 12:09:56 -0400
In-Reply-To: <1395849627-15711-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/26/2014 12:00 PM, Vlad Yasevich wrote:
> Bridge has its own way to deterine if the packet is forwardable and it doesn't
> support 8021ad tags correctly.  Instead just allow bridge to use an
> existing is_skb_forwardable() function.
> 
> 
> Vlad Yasevich (2):
>   net: Allow modules to use is_skb_forwardable
>   bridge: use is_skb_forwardable in forward path
> 
>  include/linux/netdevice.h | 1 +
>  net/bridge/br_forward.c   | 7 +------
>  net/core/dev.c            | 3 ++-
>  3 files changed, 4 insertions(+), 7 deletions(-)
> 

Self-nack.  Missed one of the hunks in patch2.

-vlad
