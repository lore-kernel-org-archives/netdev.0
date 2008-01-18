From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] [IPV4] fib_hash: fix duplicated route issue
Date: Fri, 18 Jan 2008 03:44:57 -0800 (PST)
Message-ID: <20080118.034457.47103774.davem@davemloft.net>
References: <12004820052610-git-send-email-joonwpark81@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen.hemminger@vyatta.com, green@msu.ru
To: joonwpark81@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55403
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752946AbYARLoz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2008 06:44:55 -0500
In-Reply-To: <12004820052610-git-send-email-joonwpark81@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joonwoo Park <joonwpark81@gmail.com>
Date: Wed, 16 Jan 2008 20:13:25 +0900

> http://bugzilla.kernel.org/show_bug.cgi?id=9493
> 
> The fib allows making identical routes with 'ip route replace'.
> This patch makes the fib return -EEXIST if replacement would cause duplication.
> 
> Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>

Applied.
