From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] iproute2: initialize the ll_map only once
Date: Fri, 10 Dec 2010 11:38:09 -0800
Message-ID: <20101210113809.56ea259e@nehalam>
References: <1291993190-8838-1-git-send-email-opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>,
	Vlad Dogaru <ddvlad@rosedu.org>
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51530 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756848Ab0LJTiM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Dec 2010 14:38:12 -0500
In-Reply-To: <1291993190-8838-1-git-send-email-opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 10 Dec 2010 16:59:50 +0200
Octavian Purdila <opurdila@ixiacom.com> wrote:

> Avoid initializing the LL map (which involves a costly RTNL dump)
> multiple times. This can happen when running in batch mode.
> 
> Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>

applied
-- 
