From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/7] cxgb4 patches V2
Date: Sun, 21 Feb 2010 22:30:49 -0800 (PST)
Message-ID: <20100221.223049.183064491.davem@davemloft.net>
References: <1266528256-20873-1-git-send-email-dm@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dm@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55480
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753418Ab0BVGab (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2010 01:30:31 -0500
In-Reply-To: <1266528256-20873-1-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dimitris Michailidis <dm@chelsio.com>
Date: Thu, 18 Feb 2010 13:24:09 -0800

> 
> This is V2 of the cxgb4 patches.
> 
> Changes since V1:
> - Whitespace fixed as well as some additional checkpatch issues.
> - I removed the CH_* logging wrappers.  I used the new netdev_* in a handful of
>   places but mostly stayed with the dev_* functions.
> - I added some comments to describe the register macro scheme.  As a macro
>   change would involve a rather large number of LOCs I'd really like to avoid
>   changing them.

I also told you to not use the non-standard S_*, V_*, etc. register
naming convention.

If you repost your driver without addressing all of the review
feedback you've received thus far, you are wasting people's time
because they will take time out to review your patches again
only to find that you've haven't fixed everything you've already
been made aware of.
