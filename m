From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 00/79] netfilter: netfilter update
Date: Thu, 20 Jan 2011 02:13:31 +0100
Message-ID: <4D378C3B.1020202@trash.net>
References: <1295464519-21763-1-git-send-email-kaber@trash.net>	<20110119.135504.149816150.davem@davemloft.net> <20110119.165045.25148392.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Jan Engelhardt <jengelh@computergmbh.de>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57595 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753124Ab1ATBNf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jan 2011 20:13:35 -0500
In-Reply-To: <20110119.165045.25148392.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20.01.2011 01:50, David Miller wrote:
> I'm undoing my pull, what was this build tested against?

My build tests didn't include header-install. No idea what Jan
tested against.

> In particular this commit breaks the build:
> 
> Subject: [PATCH 68/79] netfilter: xtables: add missing header files to export list
> 
> Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
>  ...
> @@ -56,6 +56,8 @@ header-y += xt_rateest.h
>  header-y += xt_realm.h
>  header-y += xt_recent.h
>  header-y += xt_sctp.h
> +header-y += xt_secmark.h
> +header-y += xt_socket.h
>  header-y += xt_state.h
>  header-y += xt_statistic.h
>  header-y += xt_string.h
> 
> No active tree has a include/linux/netfilter/xt_secmark.h file.  Therefore
> we end up with:
> 
> make[2]: `scripts/unifdef' is up to date.
> make[4]: *** No rule to make target `/home/davem/src/GIT/net-next-2.6/include/linux/netfilter/xt_secmark.h', needed by `/home/davem/src/GIT/net-next-2.6/usr/include/linux/netfilter/.install'.  Stop.
> 
> Did you mean xt_SECMARK.h (caps)?

I guess so. Jan, please fix this up.
