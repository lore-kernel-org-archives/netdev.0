From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 5/5] alx: add stats to ethtool
Date: Thu, 02 Jan 2014 14:09:14 +0100
Message-ID: <1388668154.4326.1.camel@jlt4.sipsolutions.net>
References: <1388619628-3373-1-git-send-email-sd@queasysnail.net>
	 <1388619628-3373-6-git-send-email-sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:54240 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750814AbaABNJX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 08:09:23 -0500
In-Reply-To: <1388619628-3373-6-git-send-email-sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-01-02 at 00:40 +0100, Sabrina Dubroca wrote:

> +static const char alx_gstrings_stats[][ETH_GSTRING_LEN] = {

You should probably have a comment here and on the stats struct
declaration that they must absolutely match in order/size/etc.

Maybe try to put in some BUILD_BUG_ON() as well, at least checking the
sizeof() vs. ARRAY_SIZE*sizeof(u64) - that might already have caught the
bug that Ben pointed out.

> +	"rx_packets",

Is it useful to provide stats that are already elsewhere? Then again, it
doesn't really hurt and simplifies the code ...

johannes
