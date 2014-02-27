From: David Miller <davem@redhat.com>
Subject: Re: pull request (net): ipsec 2014-02-27
Date: Thu, 27 Feb 2014 16:20:02 -0500 (EST)
Message-ID: <20140227.162002.673927416324136369.davem@redhat.com>
References: <1393481799-20492-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2142 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751155AbaB0VUW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Feb 2014 16:20:22 -0500
In-Reply-To: <1393481799-20492-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Thu, 27 Feb 2014 07:16:34 +0100

> 1) Build fix for ip_vti when NET_IP_TUNNEL is not set.
>    We need this set to have ip_tunnel_get_stats64()
>    available.
> 
> 2) Fix a NULL pointer dereference on sub policy usage.
>    We try to access a xfrm_state from the wrong array.
> 
> 3) Take xfrm_state_lock in xfrm_migrate_state_find(),
>    we need it to traverse through the state lists.
> 
> 4) Clone states properly on migration, otherwise we crash
>    when we migrate a state with aead algorithm attached.
> 
> 5) Fix unlink race when between thread context and timer
>    when policies are deleted.

Looks good, pulled, thanks Steffen.
