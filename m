From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH]: suspicious unlikely usage in tcp_transmit_skb()
Date: Wed, 26 Apr 2006 02:42:34 -0700 (PDT)
Message-ID: <20060426.024234.117307955.davem@davemloft.net>
References: <444D5E73.7020803@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:59871
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751338AbWDZJmk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Apr 2006 05:42:40 -0400
To: hzhong@gmail.com
In-Reply-To: <444D5E73.7020803@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hua Zhong <hzhong@gmail.com>
Date: Mon, 24 Apr 2006 16:25:39 -0700

> Hi,
> 
> I am developing a profiling tool to check if likely/unlikely usages are wise. I find that the following one is always a miss:
> 
>       # Hit    # miss Function:Filename@Line
> !         0     50505 tcp_transmit_skb():net/ipv4/tcp_output.c@468
> 
> There is a chance that my tool is buggy, but I just want to confirm with you whether this does look suspicious and what your opinion is.
> 
> Signed-off-by: Hua Zhong <hzhong@gmail.com>

Your patch is semantically correct but does not apply, because your
email client has turned all of the tab characters in the patch into
spaces.  This corrupts the patch and makes it unusable.

This problem is hit by pretty much every single gmail user that tries
to send a patch for the first time.  I wish gmail would not mangle
ascii text by default.

Please fix this and repost, retaining a proper changelog entry and
signed off line, thank you.
