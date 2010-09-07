From: David Miller <davem@davemloft.net>
Subject: Re: [patch] irda: off by one
Date: Mon, 06 Sep 2010 18:35:31 -0700 (PDT)
Message-ID: <20100906.183531.191390472.davem@davemloft.net>
References: <20100904131435.GL5437@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, adobriyan@gmail.com, lizf@cn.fujitsu.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40996
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755502Ab0IGBfO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Sep 2010 21:35:14 -0400
In-Reply-To: <20100904131435.GL5437@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Sat, 4 Sep 2010 15:14:35 +0200

> This is an off by one.  We would go past the end when we NUL terminate
> the "value" string at end of the function.  The "value" buffer is
> allocated in irlan_client_parse_response() or
> irlan_provider_parse_command().
> 
> CC: stable@kernel.org
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied.
