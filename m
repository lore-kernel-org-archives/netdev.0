From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: routing header fixes
Date: Wed, 12 Nov 2008 22:59:30 -0800 (PST)
Message-ID: <20081112.225930.130733700.davem@davemloft.net>
References: <491A031F.40901@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shanwei@cn.fujitsu.com
To: brian.haley@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34766
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751006AbYKMG7a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2008 01:59:30 -0500
In-Reply-To: <491A031F.40901@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brian Haley <brian.haley@hp.com>
Date: Tue, 11 Nov 2008 17:11:43 -0500

> This patch fixes two bugs:
> 
> 1. setsockopt() of anything but a Type 2 routing header should return EINVAL instead of EPERM.  Noticed by Shan Wei (shanwei@cn.fujitsu.com).
> 
> 2. setsockopt()/sendmsg() of a Type 2 routing header with invalid length or segments should return EINVAL.  These values are statically fixed in RFC 3775, unlike the variable Type 0 was.
> 
> Signed-off-by: Brian Haley <brian.haley@hp.com>

Looks good, applied, thanks Brian.
