From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] mac80211: Use ERR_CAST inlined function instead of
 ERR_PTR(PTR_ERR(...))
Date: Mon, 07 Oct 2013 18:16:39 +0200
Message-ID: <1381162599.9005.3.camel@jlt4.sipsolutions.net>
References: <1381190953-6362-1-git-send-email-duanj.fnst@cn.fujitsu.com>
	 (sfid-20131007_181007_863270_C3FC10D8)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Duan Jiong <duanj.fnst@cn.fujitsu.com>
To: djduanjiong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:57628 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755756Ab3JGQRF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Oct 2013 12:17:05 -0400
In-Reply-To: <1381190953-6362-1-git-send-email-duanj.fnst@cn.fujitsu.com> (sfid-20131007_181007_863270_C3FC10D8)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-10-07 at 17:09 -0700, djduanjiong@gmail.com wrote:

>  	if (IS_ERR(key))
> -		return ERR_PTR(PTR_ERR(key));
> +		return ERR_CAST(key);

I already have this patch in my tree.

johannes
