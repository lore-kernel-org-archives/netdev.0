From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [RFC PATCH 15/24] net: rbridge: Add basic trill frame handling
 function
Date: Wed, 24 Sep 2014 21:23:54 +0200
Message-ID: <20140924192354.GA14754@electric-eye.fr.zoreil.com>
References: <1411573940-14079-1-git-send-email-ahmed@gandi.net>
 <1411573940-14079-16-git-send-email-ahmed@gandi.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, william@gandi.net,
	f.cachereul@alphalink.fr, Kamel Haddadou <kamel@gandi.net>
To: Ahmed Amamou <ahmed@gandi.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:40732 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751076AbaIXTXz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2014 15:23:55 -0400
Content-Disposition: inline
In-Reply-To: <1411573940-14079-16-git-send-email-ahmed@gandi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ahmed Amamou <ahmed@gandi.net> :
[...]
> diff --git a/net/bridge/rbridge/rbr.c b/net/bridge/rbridge/rbr.c
> index edd1e7c..4b41d4c 100644
> --- a/net/bridge/rbridge/rbr.c
> +++ b/net/bridge/rbridge/rbr.c
> @@ -129,3 +129,103 @@ static void rbr_del_all(struct rbr *rbr)
[...]
> +	/* if trill is not enabled, handle by bridge */
> +	if (br->trill_enabled == BR_NO_TRILL) {
> +		goto handle_by_bridge;
> +	} else {

No need for an 'else' branch after a 'goto'. Please save an indent level.

Same remark apply in patches #19 and and #21 (almost: 'else' before 'goto').

-- 
Ueimor
