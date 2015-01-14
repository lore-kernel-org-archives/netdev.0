From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH mac80211-next] nl80211: Allow set network namespace by fd
Date: Wed, 14 Jan 2015 09:47:26 +0100
Message-ID: <1421225246.1950.22.camel@sipsolutions.net>
References: <1421073245-20312-1-git-send-email-vadim4j@gmail.com>
	 (sfid-20150112_154435_236040_68404050)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Vadim Kochan <vadim4j@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:58120 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752753AbbANIrb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2015 03:47:31 -0500
In-Reply-To: <1421073245-20312-1-git-send-email-vadim4j@gmail.com> (sfid-20150112_154435_236040_68404050)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-01-12 at 16:34 +0200, Vadim Kochan wrote:

> --- a/net/core/net_namespace.c
> +++ b/net/core/net_namespace.c
> @@ -361,6 +361,7 @@ struct net *get_net_ns_by_fd(int fd)
>  	return ERR_PTR(-EINVAL);
>  }
>  #endif
> +EXPORT_SYMBOL_GPL(get_net_ns_by_fd);

Does this seem OK? Vadim is adding support for using the ns-by-fd in
nl80211, which can be a module as part of cfg80211.

johannes
