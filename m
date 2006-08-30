From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix sk->sk_filter field access
Date: Wed, 30 Aug 2006 14:30:15 -0700 (PDT)
Message-ID: <20060830.143015.104035096.davem@davemloft.net>
References: <200608301707.14250.dim@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, dev@sw.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:11999
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932082AbWH3VaO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Aug 2006 17:30:14 -0400
To: dim@openvz.org
In-Reply-To: <200608301707.14250.dim@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dmitry Mishin <dim@openvz.org>
Date: Wed, 30 Aug 2006 17:07:14 +0400

> Function sk_filter() is called from tcp_v{4,6}_rcv() functions with argue 
> needlock = 0, while socket is not locked at that moment. In order to avoid 
> this and similar issues in the future, use rcu for sk->sk_filter field read 
> protection.
> 
> Patch is for net-2.6.19

What bug are you fixing?  The current code looks correct to me.

Why is it important to avoid the needlock stuff in the future?

This patch description is very incomplete, you should list the
precise reason why you are doing something instead of using
vague language.

Thanks.
