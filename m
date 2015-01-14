From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 -next v3] ip: route: add congestion control
 metric
Date: Tue, 13 Jan 2015 17:41:51 -0800
Message-ID: <20150113174151.72baf7fe@urahara>
References: <1420758786-32666-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:61455 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751058AbbANBmB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 20:42:01 -0500
Received: by mail-pd0-f173.google.com with SMTP id ft15so6683072pdb.4
        for <netdev@vger.kernel.org>; Tue, 13 Jan 2015 17:42:01 -0800 (PST)
In-Reply-To: <1420758786-32666-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  9 Jan 2015 00:13:06 +0100
Daniel Borkmann <dborkman@redhat.com> wrote:

> This patch adds configuration and dumping of congestion control metric
> for ip route, for example:
> 
>   ip route add <dst> dev foo congctl [lock] dctcp
> 
> Reference: http://thread.gmane.org/gmane.linux.network/344733
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---
>  v2->v3:
>   - use rta_getattr_u32 et al helpers
>   - regarding discussed mx(un)lock, I'll do a follow-up for
>     all users inside iproute_modify() if that is wished
>  v1->v2:
>   - adapted mxlock setting to kernel style
>   - use arg directly in rta_addattr_l
> 
>  include/linux/rtnetlink.h |  2 ++
>  ip/iproute.c              | 22 ++++++++++++++++++----
>  man/man8/ip-route.8.in    | 19 ++++++++++++++++++-
>  3 files changed, 38 insertions(+), 5 deletions(-)
> 

Applied to net-next branch.
