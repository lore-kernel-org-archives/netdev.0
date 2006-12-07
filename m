From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [patch 7/7] d80211: do not pass an invalid key index to
 set_key()
Date: Thu, 7 Dec 2006 13:25:05 +0100
Message-ID: <20061207132505.049363e6@griffin.suse.cz>
References: <20061207004238.540749000@devicescape.com>
	<20061207004540.GG16252@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:58465 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1032128AbWLGMYy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Dec 2006 07:24:54 -0500
To: David Kimdon <david.kimdon@devicescape.com>
In-Reply-To: <20061207004540.GG16252@devicescape.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 6 Dec 2006 16:45:40 -0800, David Kimdon wrote:
> Index: wireless-dev/net/d80211/ieee80211_ioctl.c
> ===================================================================
> --- wireless-dev.orig/net/d80211/ieee80211_ioctl.c
> +++ wireless-dev/net/d80211/ieee80211_ioctl.c
> @@ -612,7 +612,7 @@ static int ieee80211_set_encryption(stru
>  
>  	if (alg == ALG_NONE) {
>  		keyconf = NULL;
> -		if (try_hwaccel && key && local->ops->set_key &&
> +		if (try_hwaccel && key && key->hw_key_idx != -1 && local->ops->set_key &&

Use HW_KEY_IDX_INVALID, please.

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
