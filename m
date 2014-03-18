From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net] net: vxlan: fix crash when interface is created with
 no group
Date: Tue, 18 Mar 2014 09:41:45 -0700
Message-ID: <CAHA+R7Mpry29vbYLu9wmoE=REW1GkyPfEsbj5QxiWVdGrYtG5A@mail.gmail.com>
References: <1395055050-20874-1-git-send-email-mike.rapoport@ravellosystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>
To: Mike Rapoport <mike.rapoport@ravellosystems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f41.google.com ([209.85.215.41]:58410 "EHLO
	mail-la0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756323AbaCRQlr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2014 12:41:47 -0400
Received: by mail-la0-f41.google.com with SMTP id gl10so5111306lab.28
        for <netdev@vger.kernel.org>; Tue, 18 Mar 2014 09:41:46 -0700 (PDT)
In-Reply-To: <1395055050-20874-1-git-send-email-mike.rapoport@ravellosystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 17, 2014 at 4:17 AM, Mike Rapoport
<mike.rapoport@ravellosystems.com> wrote:
...
> The crash occurs because vxlan_rcv decides on protocol version of outer
> packed using vxlan->default_dst.remote_ip.sa.sa_family field which is
> not initialized if no multicast group was specified at interface
> creation time. This causes vxlan driver to always assume that outer
> packet is IPv6.
>
> Using IP protocol version from skb instead of default destination
> address family fixes the problem.
>
> Signed-off-by: Mike Rapoport <mike.rapoport@ravellosystems.com>

Acked-by: Cong Wang <cwang@twopensource.com>

Thanks for the fix!
