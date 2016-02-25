From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [Y2038] [PATCH 4/4] net: sctp: Convert log timestamps to be y2038 safe
Date: Thu, 25 Feb 2016 15:56:53 +0100
Message-ID: <3414163.AdCiyYLy4g@wuerfel>
References: <1456384031-29244-1-git-send-email-deepa.kernel@gmail.com> <1456384031-29244-5-git-send-email-deepa.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Deepa Dinamani <deepa.kernel@gmail.com>, netdev@vger.kernel.org,
	Vlad Yasevich <vyasevich@gmail.com>,
	linux-sctp@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: y2038@lists.linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([217.72.192.73]:54528 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760300AbcBYO5f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 09:57:35 -0500
In-Reply-To: <1456384031-29244-5-git-send-email-deepa.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 24 February 2016 23:07:11 Deepa Dinamani wrote:
> SCTP probe log timestamps use struct timespec which is
> not y2038 safe.
> Use struct timespec64 which is 2038 safe instead.
> 
> Use monotonic time instead of real time as only time
> differences are logged.
> 
> Signed-off-by: Deepa Dinamani <deepa.kernel@gmail.com>
> 

Reviewed-by: Arnd Bergmann <arnd@arndb.de>
