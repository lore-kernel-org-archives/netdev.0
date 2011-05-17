From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] netfilter: SIP conntrack fixes
Date: Tue, 17 May 2011 14:18:30 -0400 (EDT)
Message-ID: <20110517.141830.2292913195856431580.davem@davemloft.net>
References: <1305610014-3056-1-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39570 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756015Ab1EQSTg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 14:19:36 -0400
In-Reply-To: <1305610014-3056-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: kaber@trash.net
Date: Tue, 17 May 2011 07:26:52 +0200

> following are two fixes for the SIP connection tracking helper:
> 
> - missing validation of the Content-Length field, which is used to calculate
>   the end of the SDP body
> 
> - incorrect parsing of the SIP message, resulting in a failure to locate
>   the SDP body when the Content-Length field is not the last member of the
>   SIP message
> 
> Please apply or pull from:
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-2.6.git master

Pulled, thanks Patrick.
