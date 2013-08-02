From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net] net: rtm_to_ifaddr: free ifa if ifa_cacheinfo
 processing fails
Date: Fri, 2 Aug 2013 12:22:29 +0200
Message-ID: <20130802102229.GB1586@minipsycho.orion>
References: <1375435963-30009-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f169.google.com ([209.85.215.169]:36490 "EHLO
	mail-ea0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754120Ab3HBKWd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Aug 2013 06:22:33 -0400
Received: by mail-ea0-f169.google.com with SMTP id z7so236033eaf.0
        for <netdev@vger.kernel.org>; Fri, 02 Aug 2013 03:22:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1375435963-30009-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Aug 02, 2013 at 11:32:43AM CEST, dborkman@redhat.com wrote:
>Commit 5c766d642 ("ipv4: introduce address lifetime") leaves the ifa
>resource that was allocated via inet_alloc_ifa() unfreed when returning
>the function with -EINVAL. Thus, free it first via inet_free_ifa().
>
>Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Reviewed-by: Jiri Pirko <jiri@resnulli.us>
