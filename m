From: Patrick McHardy <kaber@trash.net>
Subject: Re: iproute2: git pull request from debian repo.
Date: Sun, 21 Oct 2007 19:48:21 +0200
Message-ID: <471B90E5.1040108@trash.net>
References: <20071019122753.GA30078@scream.fatal.se> <20071019130616.GH1362@baikonur.stro.at> <20071019144815.GB30444@scream.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: maximilian attems <max@stro.at>, shemminger@linux-foundation.org,
	netdev@vger.kernel.org
To: Andreas Henriksson <andreas@fatal.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59502 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751534AbXJURs4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Oct 2007 13:48:56 -0400
In-Reply-To: <20071019144815.GB30444@scream.fatal.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andreas Henriksson wrote:
> -		for (;;) {
> +		while (round < MAX_ROUNDS) {
>  			if (rtnl_wilddump_request(&rth, filter.family, RTM_GETADDR) < 0) {
>  				perror("Cannot send dump request");
>  				exit(1);
> @@ -694,6 +696,8 @@ int ipaddr_list_or_flush(int argc, char **argv, int flush)
>  				fflush(stdout);
>  			}
>  		}
> +		fprintf(stderr, "*** Flush remains incomplete after %d rounds. ***\n", MAX_ROUNDS); fflush(stderr);


Again, please make this optional. People might want to make
sure the cache is flushed even if it takes a bit longer.
