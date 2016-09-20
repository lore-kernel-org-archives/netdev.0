From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH iproute2] ipmonitor: fix ip monitor can't work when NET_NS
 is not enabled
Date: Tue, 20 Sep 2016 13:53:56 +0200
Message-ID: <69ebf5fa-aa1c-762f-308b-8c009b13cef4@6wind.com>
References: <1474362542-5506-1-git-send-email-zlpnobody@gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Liping Zhang <liping.zhang@spreadtrum.com>
To: Liping Zhang <zlpnobody@gmail.com>, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:36976 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751539AbcITLx7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 07:53:59 -0400
Received: by mail-wm0-f49.google.com with SMTP id b130so30884176wmc.0
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 04:53:59 -0700 (PDT)
In-Reply-To: <1474362542-5506-1-git-send-email-zlpnobody@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 20/09/2016 à 11:09, Liping Zhang a écrit :
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
Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
