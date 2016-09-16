From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: ipv6: Disable forwarding per interface via sysctl
Date: Fri, 16 Sep 2016 06:39:52 -0700
Message-ID: <1474033192.22679.67.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1474030076-24809-1-git-send-email-mmanning@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Mike Manning <mmanning@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:33059 "EHLO
        mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755773AbcIPNjz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2016 09:39:55 -0400
Received: by mail-pa0-f68.google.com with SMTP id oz2so3496801pac.0
        for <netdev@vger.kernel.org>; Fri, 16 Sep 2016 06:39:55 -0700 (PDT)
In-Reply-To: <1474030076-24809-1-git-send-email-mmanning@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-09-16 at 13:47 +0100, Mike Manning wrote:
> Disabling forwarding per interface via sysctl continues to allow
> forwarding. This is contrary to the sysctl documentation stating that
> the forwarding sysctl is per interface, whereas currently it is only
> the sysctl for all interfaces that has an effect on forwarding. The
> solution is to drop any received packets instead of forwarding them
> if the ingress device has a per-device forwarding sysctl that is unset.

Some archaeological research might be needed because
Documentation/networking/ip-sysctl.txt states :

IPv4 and IPv6 work differently here; e.g. netfilter must be used
to control which interfaces may forward packets and which not.

If this netfilter requirement is obsolete, then your patch would need to
change the doc as well.

Hannes can probably comment on this ?

Thanks.
