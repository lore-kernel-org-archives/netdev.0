From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/1] net: correct-Traffic-shaper-Kconfig
Date: Sun, 22 Oct 2006 18:55:09 +0200
Message-ID: <453BA26D.9010504@trash.net>
References: <43123154321532@wsc.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38343 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1751279AbWJVQzh
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Oct 2006 12:55:37 -0400
To: Jiri Slaby <jirislaby@gmail.com>
In-Reply-To: <43123154321532@wsc.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jiri Slaby wrote:
> kconfig, correct traffic shaper
> 
> CBQ is no longer experimental and is located in other subtree.
> 
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index 0a999a8..e845df9 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -2842,9 +2842,9 @@ config SHAPER
>  	  these virtual devices. See
>  	  <file:Documentation/networking/shaper.txt> for more information.
>  
> -	  An alternative to this traffic shaper is the experimental
> -	  Class-Based Queuing (CBQ) scheduling support which you get if you
> -	  say Y to "QoS and/or fair queuing" above.
> +	  An alternative to this traffic shaper is the Class-Based Queuing
> +	  (CBQ) scheduling support which you get if you say Y to
> +	  "QoS and/or fair queuing" in "Networking options".

While you're at it .. CBQ is actually not a very good alternative
since it doesn't work properly on top of virtual network devices.
The closest match for an alternative would be TBF, but HTB and
HFSC also do fine. Maybe just point to the traffic schedulers in
general. I think you could also change EXPERIMENTAL to OBSOLETE
for the shaper device, the traffic schedulers are a lot more
flexible.

