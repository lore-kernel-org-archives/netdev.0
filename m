From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: more #ifdef CONFIG_COMPAT
Date: Thu, 28 Aug 2008 02:54:05 -0700 (PDT)
Message-ID: <20080828.025405.255750748.davem@davemloft.net>
References: <20080826024721.GA5056@x200.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47150
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751503AbYH1JyK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2008 05:54:10 -0400
In-Reply-To: <20080826024721.GA5056@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Tue, 26 Aug 2008 06:47:21 +0400

> All users of struct proto::compat_[gs]etsockopt and
> struct inet_connection_sock_af_ops::compat_[gs]etsockopt are under
> #ifdef already, so use it in structure definition too.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied to net-next-2.6, thanks Alexey.
