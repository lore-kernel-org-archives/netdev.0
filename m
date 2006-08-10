From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/5] sock_register interface changes
Date: Wed, 09 Aug 2006 21:03:43 -0700 (PDT)
Message-ID: <20060809.210343.125564229.davem@davemloft.net>
References: <20060809183138.332023530@localhost.localdomain>
	<20060809183349.701469780@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulmck@us.ibm.com, netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:17307
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932494AbWHJEDg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Aug 2006 00:03:36 -0400
To: shemminger@osdl.org
In-Reply-To: <20060809183349.701469780@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Wed, 09 Aug 2006 11:31:43 -0700

> The sock_register() doesn't change the family, so the protocols can
> define it read-only.  No caller ever checks return value from
> sock_unregister()

Applied, thanks.
