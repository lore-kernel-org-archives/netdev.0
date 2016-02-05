From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ipmonitor: match user option 'all' before
 'all-nsid'
Date: Fri, 5 Feb 2016 11:48:38 +1100
Message-ID: <20160205114838.62917129@samsung9>
References: <1454460820-21851-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nicolas.dichtel@6wind.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:35548 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750947AbcBEAsr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2016 19:48:47 -0500
Received: by mail-pa0-f53.google.com with SMTP id ho8so24278979pac.2
        for <netdev@vger.kernel.org>; Thu, 04 Feb 2016 16:48:46 -0800 (PST)
In-Reply-To: <1454460820-21851-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue,  2 Feb 2016 16:53:40 -0800
Roopa Prabhu <roopa@cumulusnetworks.com> wrote:

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> 'ip monitor all' is broken on older kernels.
> This patch fixes 'ip monitor all' to match
> 'all' and not 'all-nsid'.
> 
> It moves parsing arg 'all-nsid' to after parsing
> 'all'.
> 
> Before:
> $ip monitor all
> NETLINK_LISTEN_ALL_NSID: Protocol not available
> 
> After:
> $ip monitor all
> [NEIGH]Deleted 10.0.0.1 dev eth1 lladdr c4:54:44:4f:b2:dd STALE
> 
> Fixes: 449b824ad196 ("ipmonitor: allows to monitor in several netns")
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Applied thanks.
