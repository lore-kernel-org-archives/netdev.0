From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: usb: initialize tmp in dm9601.c to avoid warning
Date: Fri, 18 Jan 2013 14:29:53 -0500 (EST)
Message-ID: <20130118.142953.1976568254852992204.davem@davemloft.net>
References: <1358450989-25205-1-git-send-email-sque@chromium.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jacmet@sunsite.dk, netdev@vger.kernel.org, msb@chromium.org
To: sque@chromium.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38716 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751829Ab3ART3z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2013 14:29:55 -0500
In-Reply-To: <1358450989-25205-1-git-send-email-sque@chromium.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Que <sque@chromium.org>
Date: Thu, 17 Jan 2013 11:29:49 -0800

> In two places, tmp is initialized implicitly by being passed as a
> pointer during a function call.  However, this is not obvious to the
> compiler, which logs a warning.
> 
> Signed-off-by: Simon Que <sque@chromium.org>

Applied to net-next, thanks.
