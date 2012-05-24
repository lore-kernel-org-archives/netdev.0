From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH IPROUTE2] tc-codel: Add manpage
Date: Thu, 24 May 2012 06:53:59 +0200
Message-ID: <1337835239.3361.3954.camel@edumazet-glaptop>
References: <1337834034-27803-1-git-send-email-subramanian.vijay@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>,
	Dave Taht <dave.taht@gmail.com>
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:45880 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750944Ab2EXEyD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2012 00:54:03 -0400
Received: by eeit10 with SMTP id t10so2297317eei.19
        for <netdev@vger.kernel.org>; Wed, 23 May 2012 21:54:01 -0700 (PDT)
In-Reply-To: <1337834034-27803-1-git-send-email-subramanian.vijay@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-05-23 at 21:33 -0700, Vijay Subramanian wrote:
> This patch adds the manpage for the CoDel (Controlled-Delay) AQM.
> 
> Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
> ---

Thanks !

> +.SS target
> +is the acceptable minimum standing/persistent queue delay. This minimum delay
> +is identified by tracking the local minimum queue delay that packets experience.
> +Default and recommended value is 5ms.

Although I can tell I prefer lower values on hosts.

On 10Gbe links, I used 500us target

> +
> +.SS interval
> +is used to ensure that the measured minimum delay does not become too stale. The
> +minimum delay must be experienced in the last epoch of length
> +.B interval.
> +It should be set on the order of the worst-case RTT through the bottleneck to
> +give endpoints sufficient time to react.  Default value is 100ms.

Same here. In a datacenter, you might reduce this to 20ms or so...
