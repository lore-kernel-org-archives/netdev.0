From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] arm_arch_timer: include clocksource.h directly
Date: Tue, 06 Jan 2015 13:27:19 -0500 (EST)
Message-ID: <20150106.132719.85215859897492631.davem@davemloft.net>
References: <1420550773-6752-1-git-send-email-richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux@roeck-us.net
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52185 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751453AbbAFS1W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 13:27:22 -0500
In-Reply-To: <1420550773-6752-1-git-send-email-richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>
Date: Tue,  6 Jan 2015 14:26:13 +0100

> This driver makes use of the clocksource code. Previously it had only
> included the proper header indirectly, but that chain was inadvertently
> broken by 74d23cc "time: move the timecounter/cyclecounter code into its
> own file."
> 
> This patch fixes the issue by including clocksource.h directly.
> 
> Signed-off-by: Richard Cochran <richardcochran@gmail.com>

Applied.
