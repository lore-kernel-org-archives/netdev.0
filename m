From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp-lp: prevent chance for oops
Date: Thu, 28 Sep 2006 14:38:01 -0700 (PDT)
Message-ID: <20060928.143801.14991553.davem@davemloft.net>
References: <3feffd230609280343o1975ee70o8a55acf3e5d4769e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:47799
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932130AbWI1Vh5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 17:37:57 -0400
To: hswong3i@gmail.com
In-Reply-To: <3feffd230609280343o1975ee70o8a55acf3e5d4769e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Wong Edison" <hswong3i@gmail.com>
Date: Thu, 28 Sep 2006 18:43:58 +0800

> This patch fix the chance for tcp_lp_remote_hz_estimator return 0, if
> 0 < rhz < 64. It also make sure the flag LP_VALID_RHZ is set
> correctly.
> 
> Signed-off-by: Wong Hoi Sing Edison <hswong3i@gmail.com>

Applied, thanks.
