From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] skb leakage in inet6_csk_xmit
Date: Wed, 10 May 2006 13:24:54 -0700 (PDT)
Message-ID: <20060510.132454.41229490.davem@davemloft.net>
References: <20060510090216.GA1968@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:52694
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932468AbWEJUZ0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 May 2006 16:25:26 -0400
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <20060510090216.GA1968@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Date: Wed, 10 May 2006 13:02:16 +0400

> inet6_csk_xit does not free skb when routing fails.
> 
> Signed-off-by: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>

Applied, thanks a lot.
