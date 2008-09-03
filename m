From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND] ipv6: return with appropriate error code when
 sending RH0 using setsockopt()
Date: Wed, 03 Sep 2008 02:23:03 -0700 (PDT)
Message-ID: <20080903.022303.84950778.davem@davemloft.net>
References: <48BE4DA2.20800@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shanwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40432
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750773AbYICJXK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 05:23:10 -0400
In-Reply-To: <48BE4DA2.20800@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shan Wei <shanwei@cn.fujitsu.com>
Date: Wed, 03 Sep 2008 16:41:06 +0800

>  I'm sorry to resend the patch, for that no one replied it from Jun 27.
> 
>  The kernel had removed the RH0(Type 0 Routing Header), but we can still
>  send IPv6 packet with RH0 using sendmsg() or setsockopt().
> 
>  Compare with sendmsg() that returns EINVAL, but setsockopt() return EPERM.
>  The patch fix it.
> 
> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>

I've tried to defer IPV6 patches that have semantic issues to an
expert such as Yoshifuji-san, but he has dropped off the face of the
planet for a while.

I'll take a look at this if I get a chance.
