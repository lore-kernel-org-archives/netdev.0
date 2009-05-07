From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]ipv6:use ipv6_addr_type instead of __ipv6_addr_type
Date: Thu, 07 May 2009 14:59:31 -0700 (PDT)
Message-ID: <20090507.145931.179746218.davem@davemloft.net>
References: <4A02921A.1090200@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: yanghy@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53502
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753316AbZEGV7g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2009 17:59:36 -0400
In-Reply-To: <4A02921A.1090200@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yang Hongyang <yanghy@cn.fujitsu.com>
Date: Thu, 07 May 2009 15:47:38 +0800

> Although the function of these two functions are the same,we should use the
> encapsulation function of __ipv6_addr_type
> 
> Signed-off-by: Yang Hongyang<yanghy@cn.fujitsu.com>

Are you sure?  ipv6_addr_type() masks out the upper 16-bits
of __ipv6_addr_type()'s return value, which is the scope.

I'm not convinced that is what we want to do here.
