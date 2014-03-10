From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net-next] netdev: set __percpu attribute on netdev_alloc_pcpu_stats
Date: Mon, 10 Mar 2014 10:44:58 -0700
Message-ID: <CAHA+R7O7rubEa_Pi323_TNJCd0Jn-gpwfgEg89gnSiFi-TGuWQ@mail.gmail.com>
References: <20140310094146.2aaa8e0e@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, Cong Wang <amwang@redhat.com>,
	netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:52405 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752602AbaCJRpA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 13:45:00 -0400
Received: by mail-la0-f50.google.com with SMTP id y1so4955059lam.9
        for <netdev@vger.kernel.org>; Mon, 10 Mar 2014 10:44:58 -0700 (PDT)
In-Reply-To: <20140310094146.2aaa8e0e@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 10, 2014 at 9:41 AM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> This patch fixes sparse warnings in vlan driver.
> It propagates the sparse __percpu attribute from alloc_percpu
> into netdev_alloc_pcpu_stats. I expect it may trigger additional
> sparse warnings from other drivers that are missing the __percpu
> attribute.
>
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Acked-by: Cong Wang <cwang@twopensource.com>

Thanks for the fix.
