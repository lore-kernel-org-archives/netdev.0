From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH 1/8] d80211/bcm43xx: Modify struct ieee80211_rx_status
	for wireless statistics.
Date: Wed, 09 Aug 2006 10:22:26 -0400
Message-ID: <1155133346.3615.1.camel@localhost.localdomain>
References: <44D92535.8090303@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:36790 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1750889AbWHIOVd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 10:21:33 -0400
To: Larry Finger <Larry.Finger@lwfinger.net>
In-Reply-To: <44D92535.8090303@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-08-08 at 18:58 -0500, Larry Finger wrote:
> Part 1 of 8 to add wireless statistics to the bcm43xx-d80211 system. This patch adds new variables
> to struct ieee80211_rx_status to contain the latest values for signal, noise, and the maximum value
> of the received ssi. These could be u8's, but I left them as integers in case other drivers needed
> larger values.
> 
> The patch is for the August 8 version of Linville's wireless-dev tree.
> 
> Signed-Off-By: Larry Finger <Larry.Finger@lwfinger.net>
> 
> 
> 
> 
> diff --git a/include/net/d80211.h b/include/net/d80211.h
> index ba5cb4c..8479b58 100644
> --- a/include/net/d80211.h
> +++ b/include/net/d80211.h
> @@ -205,6 +205,9 @@ struct ieee80211_rx_status {
>           int channel;
>           int phymode;
>           int ssi;
> +	int maxssi;
> +	int signal;
> +	int noise;

Spacing?  Looks like you're using real tabs here, but the current code
uses 8 spaces instead.  Not sure if that's a problem.

Dan

>           int antenna;
>           int rate;
>           int flag;
> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

