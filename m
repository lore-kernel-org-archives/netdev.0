From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] sockfd_lookup_light() returns random error for -EBADFD
Date: Wed, 19 Apr 2006 15:25:34 -0700 (PDT)
Message-ID: <20060419.152534.02098739.davem@davemloft.net>
References: <444688F2.5060909@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	torvalds@osdl.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:34785
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751286AbWDSWZd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Apr 2006 18:25:33 -0400
To: hzhong@gmail.com
In-Reply-To: <444688F2.5060909@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hua Zhong <hzhong@gmail.com>
Date: Wed, 19 Apr 2006 12:01:06 -0700

> There is a missing initialization of err in sockfd_lookup_light() that could return random error for an invalid file handle.
> 
> Signed-off-by: Hua Zhong <hzhong@gmail.com>

Applied, thanks a lot for this bug fix.
