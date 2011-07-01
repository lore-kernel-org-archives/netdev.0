From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 1/2] jme: Fix compile warning introduced
 by new pm macro
Date: Thu, 30 Jun 2011 23:54:57 -0700 (PDT)
Message-ID: <20110630.235457.469685964871620732.davem@davemloft.net>
References: <1309238615-25590-1-git-send-email-cooldavid@cooldavid.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, arieslee@jmicron.com, devinchiu@jmicron.com
To: cooldavid@cooldavid.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54056 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754957Ab1GAG4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2011 02:56:05 -0400
In-Reply-To: <1309238615-25590-1-git-send-email-cooldavid@cooldavid.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Date: Tue, 28 Jun 2011 13:23:34 +0800

> From: Guo-Fu Tseng <cooldavid@cooldavid.org>
> 
> SIMPLE_DEV_PM_OPS is using SET_SYSTEM_SLEEP_PM_OPS
> and SET_SYSTEM_SLEEP_PM_OPS is empty when CONFIG_PM_SLEEP
> is not defined.
> 
> Switching #ifdef CONFIG_PM to #ifdef CONFIG_PM_SLEEP
> 
> Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>

Applied
