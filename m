From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net v4] ipv6: mld: fix add_grhead skb_over_panic for devs
 with large MTUs
Date: Wed, 5 Nov 2014 14:11:39 -0800
Message-ID: <CAHA+R7NKPvhut_K+xgtyJqd=a8Y=dfU80e8C7Jo1qgTdg=2ubg@mail.gmail.com>
References: <1415215658-10054-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, lw1a2.jing@gmail.com,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David L Stevens <david.stevens@oracle.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f178.google.com ([209.85.216.178]:56942 "EHLO
	mail-qc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750796AbaKEWLq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 17:11:46 -0500
Received: by mail-qc0-f178.google.com with SMTP id b13so1538583qcw.23
        for <netdev@vger.kernel.org>; Wed, 05 Nov 2014 14:11:45 -0800 (PST)
In-Reply-To: <1415215658-10054-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 5, 2014 at 11:27 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
> -static struct sk_buff *mld_newpack(struct inet6_dev *idev, int size)
> +static struct sk_buff *mld_newpack(struct inet6_dev *idev, unsigned int mtu)

For net-next, you probably want to get rid of the 'mtu' parameter,
since all callers use dev->mtu. :)
