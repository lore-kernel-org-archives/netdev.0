From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: 8390: pcnet_cs: Use setup_timer and mod_timer
Date: Sun, 01 Mar 2015 13:55:48 -0500 (EST)
Message-ID: <20150301.135548.40525453362807361.davem@davemloft.net>
References: <20150227182303.GA20171@vaishali-Ideapad-Z570>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: vthakkar1994@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43198 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752801AbbCASzu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2015 13:55:50 -0500
In-Reply-To: <20150227182303.GA20171@vaishali-Ideapad-Z570>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vaishali Thakkar <vthakkar1994@gmail.com>
Date: Fri, 27 Feb 2015 23:53:03 +0530

> Use timer API functions setup_timer and mod_timer instead
> of structure assignments as they are standard way to set
> the timer and to update the expire field of an active timer
> respectively.
> 
> This is done using Coccinelle and semantic patch used for
> this is as follows:
...
> Signed-off-by: Vaishali Thakkar <vthakkar1994@gmail.com>

Applied.
