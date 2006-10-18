From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [patch 3/3] d80211: silence sparse warning: bad constant
 expression
Date: Wed, 18 Oct 2006 15:56:07 +0200
Message-ID: <20061018155607.2320a5fa@griffin.suse.cz>
References: <20061009170159.804032000@devicescape.com>
	<20061009170345.GC27239@devicescape.com>
	<20061009201102.GA10661@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:14307 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1750730AbWJRN4J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2006 09:56:09 -0400
To: David Kimdon <david.kimdon@devicescape.com>
In-Reply-To: <20061009201102.GA10661@devicescape.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 9 Oct 2006 13:11:02 -0700, David Kimdon wrote:
> --- wireless-dev.orig/net/d80211/ieee80211_sta.c
> +++ wireless-dev/net/d80211/ieee80211_sta.c
> @@ -930,8 +930,8 @@ static void ieee80211_rx_mgmt_auth(struc
>  		printk(KERN_DEBUG "%s: AP denied authentication (auth_alg=%d "
>  		       "code=%d)\n", dev->name, ifsta->auth_alg, status_code);
>  		if (status_code == WLAN_STATUS_NOT_SUPPORTED_AUTH_ALG) {
> -			const int num_algs = 3;
> -			u8 algs[num_algs];
> +			u8 algs[3];
> +			const int num_algs = ARRAY_SIZE(algs);

Wouldn't it be better just to use ARRAY_SIZE(algs) and get rid of
num_algs completely?

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
