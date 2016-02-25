From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 2/4] net: ipv4: Use y2038 safe functions and data structures
Date: Thu, 25 Feb 2016 15:57:49 +0100
Message-ID: <4264103.2ioXPnMr1j@wuerfel>
References: <1456384031-29244-1-git-send-email-deepa.kernel@gmail.com> <1456384031-29244-3-git-send-email-deepa.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, y2038@lists.linaro.org,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Deepa Dinamani <deepa.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.130]:55116 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760740AbcBYO6C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 09:58:02 -0500
In-Reply-To: <1456384031-29244-3-git-send-email-deepa.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 24 February 2016 23:07:09 Deepa Dinamani wrote:
> ICMP timestamp messages and IP source route options require
> timestamps to be in milliseconds modulo 24 hours from
> midnight UT format.
> 
> Timestamps are calculated from realtime by making a call
> to getnstimeofday() which uses struct timespec.
> timespec is not y2038 safe.
> Replace the above calls with y2038 safe current_nw_time() to
> obtain network timestamps which uses y2038 safe struct timespec64.
> 
> Signed-off-by: Deepa Dinamani <deepa.kernel@gmail.com>
> 

Reviewed-by: Arnd Bergmann <arnd@arndb.de>
