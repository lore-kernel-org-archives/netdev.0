From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ipmonitor: fix ip monitor can't work when
 NET_NS is not enabled
Date: Wed, 21 Sep 2016 16:33:40 -0700
Message-ID: <20160921163340.5af57e7c@xeon-e3>
References: <1474362542-5506-1-git-send-email-zlpnobody@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nicolas.dichtel@6wind.com,
        Liping Zhang <liping.zhang@spreadtrum.com>
To: Liping Zhang <zlpnobody@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:34438 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754064AbcIUXeF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2016 19:34:05 -0400
Received: by mail-pf0-f169.google.com with SMTP id p64so23903930pfb.1
        for <netdev@vger.kernel.org>; Wed, 21 Sep 2016 16:33:30 -0700 (PDT)
In-Reply-To: <1474362542-5506-1-git-send-email-zlpnobody@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 20 Sep 2016 02:09:02 -0700
Liping Zhang <zlpnobody@gmail.com> wrote:

> From: Liping Zhang <liping.zhang@spreadtrum.com>
> 
> In ip monitor, netns_map_init will check getnsid is supported or not.
> But when /proc/self/ns/net does not exist, we just print out error
> messages and exit. So user cannot use ip monitor anymore when
> CONFIG_NET_NS is disabled:
>   # ip monitor
>   open("/proc/self/ns/net"): No such file or directory
> 
> If open "/proc/self/ns/net" failed, set have_rtnl_getnsid to false.
> 
> Fixes: d652ccbf8195 ("netns: allow to dump and monitor nsid")
> Signed-off-by: Liping Zhang <liping.zhang@spreadtrum.com>

Makes sense. Applied.
