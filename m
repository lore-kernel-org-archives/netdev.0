From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH 2/2] d80211: Add software sequence support
Date: Mon, 5 Feb 2007 18:37:14 +0100
Message-ID: <20070205183714.3d89ec61@griffin.suse.cz>
References: <200701312016.52221.IvDoorn@gmail.com>
	<200702031245.27035.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "John Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
To: Ivo van Doorn <ivdoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:41755 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752500AbXBERhW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Feb 2007 12:37:22 -0500
In-Reply-To: <200702031245.27035.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 3 Feb 2007 12:45:26 +0100, Ivo van Doorn wrote:
> --- dscape/net/d80211/ieee80211_i.h	2007-01-31 19:41:53.000000000 +0100
> +++ dscape_seq/net/d80211/ieee80211_i.h	2007-01-31 20:06:26.000000000 +0100
> @@ -405,6 +405,7 @@
>  	int *supp_rates[NUM_IEEE80211_MODES];
>  	int *basic_rates[NUM_IEEE80211_MODES];
>  
> +	u16 seq_counter;

Shouldn't this be per-BSS?

 Jiri

-- 
Jiri Benc
SUSE Labs
