From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next 0/7] net: introduce generic type and helpers
 for IP address
Date: Thu, 25 Jul 2013 20:30:10 +0800
Message-ID: <1374755410.29923.3.camel@cr0>
References: <1374476713-8838-1-git-send-email-amwang@redhat.com>
	 <20130724.142817.216302535679937307.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26731 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755553Ab3GYMac (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jul 2013 08:30:32 -0400
In-Reply-To: <20130724.142817.216302535679937307.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-07-24 at 14:28 -0700, David Miller wrote:
> 
> You're creating bloat in places that don't need a full sockaddr_in{,6}.
> 
> There is a reason some of these pieces of code used custom types, to
> minimize the overhead.

Do you mean the inetpeer part? I can drop it if you think it harms
performance. Actually it only increases the struct by 8 bytes, if I do
calculation correctly.

Thanks.
