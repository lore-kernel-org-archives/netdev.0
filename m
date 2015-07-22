From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net] bridge: netlink: fix slave_changelink/br_setport
 race conditions
Date: Wed, 22 Jul 2015 14:52:57 +0200
Message-ID: <20150722125257.GA2219@nanopsycho.orion>
References: <1437563020-23506-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	bridge@lists.linux-foundation.org, stephen@networkplumber.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:37109 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932952AbbGVMxA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 08:53:00 -0400
Received: by wibud3 with SMTP id ud3so170984027wib.0
        for <netdev@vger.kernel.org>; Wed, 22 Jul 2015 05:52:59 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1437563020-23506-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Jul 22, 2015 at 01:03:40PM CEST, razor@blackwall.org wrote:
>From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>
>Since slave_changelink support was added there have been a few race
>conditions when using br_setport() since some of the port functions it
>uses require the bridge lock. It is very easy to trigger a lockup due to
>some internal spin_lock() usage without bh disabled, also it's possible to
>get the bridge into an inconsistent state.
>
>Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>Fixes: 3ac636b8591c ("bridge: implement rtnl_link_ops->slave_changelink")

Looks fine to me, thanks for this fix.

Reviewed-by: Jiri Pirko <jiri@resnulli.us>
