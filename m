From: Pavel Roskin <proski@gnu.org>
Subject: Re: [PATCH v2 4/7] drivers/net/wireless: Use STD_IW_HANDLER macro
Date: Thu, 18 Mar 2010 13:25:26 -0400
Message-ID: <1268933126.24544.18.camel@mj>
References: <cover.1268892663.git.joe@perches.com>
	 <b628c684e970196a7c4c0966ddd599a4c2ce293e.1268892664.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Richard Kennedy <richard@rsk.demon.co.uk>,
	Johannes Berg <johannes@sipsolutions.net>,
	Corey Thomas <coreythomas@charter.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from c60.cesmail.net ([216.154.195.49]:51867 "EHLO c60.cesmail.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752329Ab0CRRZ1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Mar 2010 13:25:27 -0400
In-Reply-To: <b628c684e970196a7c4c0966ddd599a4c2ce293e.1268892664.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-03-17 at 23:21 -0700, Joe Perches wrote:
> Convert direct uses of [ (foo - SIOCIWFIRST) , fn)
> 
> Signed-off-by: Joe Perches <joe@perches.com>
...
>  static const iw_handler	wl3501_handler[] = {
> -	[SIOCGIWNAME	- SIOCIWFIRST] = wl3501_get_name,
...
> +	STD_IW_HANDLER(SIOCGIWNAME, wl3501_get_name),

You are introducing an unnecessary cast here.  That's bad.

-- 
Regards,
Pavel Roskin
