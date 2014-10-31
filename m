From: Cong Wang <cwang@twopensource.com>
Subject: Re: [Patch net-next] neigh: remove dynamic neigh table registration support
Date: Fri, 31 Oct 2014 13:39:23 -0700
Message-ID: <CAHA+R7MvCkS1p6CDgL9=DocTDDM-ZvC6A7vM8Z8sYGj45gX2-Q@mail.gmail.com>
References: <1414787651-8499-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:59273 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750889AbaJaUjY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2014 16:39:24 -0400
Received: by mail-la0-f46.google.com with SMTP id hs14so7014212lab.33
        for <netdev@vger.kernel.org>; Fri, 31 Oct 2014 13:39:23 -0700 (PDT)
In-Reply-To: <1414787651-8499-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 31, 2014 at 1:34 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> +       switch (family) {
> +       case AF_INET:
> +               tbl = neigh_tables[NEIGH_ARP_TABLE];
> +               break;
> +#if IS_ENABLED(CONFIG_IPV6)
> +       case AF_INET6:
> +               tbl = neigh_tables[NEIGH_ND_TABLE];
> +               break;
> +#endif
> +#if IS_ENABLED(CONFIG_DECNET)
> +       case AF_DECnet:
> +               tbl = neigh_tables[NEIGH_DN_TABLE];
> +               break;
> +#endif

These #ifdef's are not necessary, I will update it after getting other
feedbacks.
