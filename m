From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] Add ip route {save,restore}
Date: Wed, 4 Aug 2010 14:03:17 -0700
Message-ID: <20100804140317.61cf3a60@nehalam>
References: <1274460311-4036-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dan Smith <danms@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37940 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758260Ab0HDVDV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Aug 2010 17:03:21 -0400
In-Reply-To: <1274460311-4036-1-git-send-email-danms@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 21 May 2010 09:45:11 -0700
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
> The only change since the RFC is the addition of manpage and doc
> material.
> 
> Signed-off-by: Dan Smith <danms@us.ibm.com>

I think Jamal/Alexey original intent was that output of show
command could be piped back in, allowing the same kind of
save/restore without special format.

But probably over the intervening time, the output format diverged
and that isn't possible.
