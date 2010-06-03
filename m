From: David Miller <davem@davemloft.net>
Subject: Re: [patch] tehuti: return -EFAULT on copy_to_user errors
Date: Thu, 03 Jun 2010 03:29:22 -0700 (PDT)
Message-ID: <20100603.032922.93373171.davem@davemloft.net>
References: <20100603100535.GT5483@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: baum@tehutinetworks.net, andy@greyhouse.net, jpirko@redhat.com,
	shemminger@vyatta.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50288
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933843Ab0FCK3M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 06:29:12 -0400
In-Reply-To: <20100603100535.GT5483@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Thu, 3 Jun 2010 12:05:35 +0200

> copy_to_user() returns the number of bytes remaining but we want to
> return a negative error code here.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied.
