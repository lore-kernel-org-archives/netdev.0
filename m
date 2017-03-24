From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [iproute2 net-next v2 0/3] ip netconf improvements
Date: Fri, 24 Mar 2017 09:37:40 +0100
Message-ID: <77c62847-e1ae-ebda-64ae-7e04fecbace7@6wind.com>
References: <1490323882-11609-1-git-send-email-dsa@cumulusnetworks.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
To: David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org,
        stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:38228 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751564AbdCXIho (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 04:37:44 -0400
Received: by mail-wm0-f51.google.com with SMTP id t189so7269690wmt.1
        for <netdev@vger.kernel.org>; Fri, 24 Mar 2017 01:37:42 -0700 (PDT)
In-Reply-To: <1490323882-11609-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 24/03/2017 à 03:51, David Ahern a écrit :
> Currently, ip netconf only shows data for ipv4 and ipv6 for dumps
> and just ipv4 for device requests. Improve the user experience by
> using the new kernel patch to dump all address families that have
> registered. For example, if mpls_router module is loaded then mpls
> values are displayed along with ipv4 and ipv6.
> 
> If the new feature is not supported (new iproute2 on older kernel)
> the kernel returns the nlmsg error EOPNOTSUPP which can be trapped
> and fallback to existing behavior.
Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
