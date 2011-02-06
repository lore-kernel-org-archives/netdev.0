From: Sakari Ailus <sakari.ailus@iki.fi>
Subject: Re: tlan: Code cleanup: checkpatch.pl is relatively happy now.
Date: Sun, 06 Feb 2011 15:24:10 +0200
Message-ID: <4D4EA0FA.6030603@iki.fi>
References: <20110206104330.GA4384@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-68.nebula.fi ([83.145.220.68]:42320 "EHLO
	smtp-68.nebula.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752397Ab1BFNYN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Feb 2011 08:24:13 -0500
In-Reply-To: <20110206104330.GA4384@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dan,

Dan Carpenter wrote:
> Commit c659c38b279657 "tlan: Code cleanup: checkpatch.pl is relatively
> happy now." includes the following change without explanation.
>
> -               if ( ( head_list->cStat&  TLAN_CSTAT_READY ) == TLAN_CSTAT_READY ) {
> +               if (head_list->c_stat&  TLAN_CSTAT_READY) {
>
> Was this a bug fix or a bug introduce?

Ouch. Introduce in this case, unfortunately. I *thought* 
TLAN_CSTAT_READY would have been a single bit instead of a bit mask. I 
should have actually checked it, and still put that change into a 
separate patch.

This might not be the one and only place where this kind of shortcut was 
made --- for 80 characters per line compliance. There are very few, 
anyway, in similar places.

I'll recheck the patch and provide a correction, in the coming days likely.

Many thanks for finding this!

-- 
Sakari Ailus
sakari.ailus@iki.fi
