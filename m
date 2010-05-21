From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] [RFC] Add ip route {save,restore}
Date: Fri, 21 May 2010 08:26:56 -0700
Message-ID: <20100521082656.7deb05c7@nehalam>
References: <1274454863-5146-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dan Smith <danms@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:36970 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753567Ab0EUP1n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 May 2010 11:27:43 -0400
In-Reply-To: <1274454863-5146-1-git-send-email-danms@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 21 May 2010 08:14:23 -0700
Dan Smith <danms@us.ibm.com> wrote:

> This patch adds save and restore commands to "ip route". Save dumps
> the RTNL stream to stdout which can then be passed to restore later.
> This may be helpful in some normal situations, and will allow C/R to
> migrate the routing information in userspace.  Tweaking of the stream
> can be done by userspace helpers to convert between versions and adjust
> things like device indexes when restoring routes in a different
> environment.
> 
> By factoring out some of the common bits of print_route() into
> filter_nlmsg(), the "save" command can use the same selection logic
> as "list," allowing the caller to save only specific routes as
> necessary.
> 
> Signed-off-by: Dan Smith <danms@us.ibm.com>

Looks good, please add man page and doc entry for this in final
version.
