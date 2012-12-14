From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH iproute2 v2] ip: use rtnelink to manage mroute
Date: Fri, 14 Dec 2012 10:10:04 -0800
Message-ID: <20121214101004.56a1fb62@nehalam.linuxnetplumber.net>
References: <20121212102617.0a3249e4@nehalam.linuxnetplumber.net>
	<1355390202-6868-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42785 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754461Ab2LNSLS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Dec 2012 13:11:18 -0500
In-Reply-To: <1355390202-6868-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 13 Dec 2012 10:16:42 +0100
Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:

> mroute was using /proc/net/ip_mr_[vif|cache] to display mroute entries. Hence,
> only RT_TABLE_DEFAULT was displayed and only IPv4.
> With rtnetlink, it is possible to display all tables for IPv4 and IPv6. The output
> format is kept. Also, like before the patch, statistics are displayed when user specify
> the '-s' argument.
> 
> The patch also adds the support of 'ip monitor mroute', which is now possible.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied. I had to clean up some merge conflicts because of applying your
patches out of order. It would help if you would recheck the version
that I just pushed to git.
