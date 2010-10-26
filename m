From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: [PATCH] ipv4: Flush per-ns routing cache more sanely.
Date: Tue, 26 Oct 2010 20:57:29 +0200
Message-ID: <4CC72499.9020502@free.fr>
References: <20101026.103428.179941457.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1-g21.free.fr ([212.27.42.1]:44775 "EHLO smtp1-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753080Ab0JZS6U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Oct 2010 14:58:20 -0400
In-Reply-To: <20101026.103428.179941457.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/26/2010 07:34 PM, David Miller wrote:
> Flush the routing cache only of entries that match the
> network namespace in which the purge event occurred.
>
> Signed-off-by: David S. Miller<davem@davemloft.net>
> ---
>
> Could I get some testing and performance analysis feedback
> on this change?  I don't want it to just die :-)
>    

Ok, will do in a couple of days.

Thanks
   -- Daniel

