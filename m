From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] make net/core/skbuff.c:skb_release_data() static
Date: Fri, 23 Jun 2006 04:01:15 -0700 (PDT)
Message-ID: <20060623.040115.108744369.davem@davemloft.net>
References: <20060623105623.GT9111@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:65517
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S933004AbWFWLBS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jun 2006 07:01:18 -0400
To: bunk@stusta.de
In-Reply-To: <20060623105623.GT9111@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>
Date: Fri, 23 Jun 2006 12:56:23 +0200

> skb_release_data() no longer has any users in other files.
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

If you are going to do this, you need to remove the reference
in arch/x86_64/kernel/functionlist too.

Thanks.
