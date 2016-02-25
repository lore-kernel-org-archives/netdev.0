From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [Y2038] [PATCH 1/4] kernel: time: Add current_nw_timestamp() for network timestamps
Date: Thu, 25 Feb 2016 15:56:30 +0100
Message-ID: <6117501.V63TZYo9Wq@wuerfel>
References: <1456384031-29244-1-git-send-email-deepa.kernel@gmail.com> <1456384031-29244-2-git-send-email-deepa.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Deepa Dinamani <deepa.kernel@gmail.com>, netdev@vger.kernel.org,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	James Morris <jmorris@namei.org>,
	Patrick McHardy <kaber@trash.net>,
	John Stultz <john.stultz@linaro.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Thomas Gleixner <tglx@linutronix.de>,
	"David S. Miller" <davem@davemloft.net>
To: y2038@lists.linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.131]:55204 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760300AbcBYO5D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 09:57:03 -0500
In-Reply-To: <1456384031-29244-2-git-send-email-deepa.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 24 February 2016 23:07:08 Deepa Dinamani wrote:
> ICMP timestamp messages and IP source route options require
> timestamps to be in milliseconds modulo 24 hours from
> midnight UTC format.
> 
> Add a time function to support this. The function returns the
> required timestamp in network byte order.
> 
> The function also uses y2038 safe time functions and data
> structures.
> 
> Signed-off-by: Deepa Dinamani <deepa.kernel@gmail.com>
> 

For the implementation:

Reviewed-by: Arnd Bergmann <arnd@arndb.de>

For where to put the code, I have no better idea, but I agree
with Hideaki Yoshifuji that it's a bit odd to place it in
kernel/*.c when it's only used by net/ipv4.

	Arnd
