From: Cong Wang <cwang@twopensource.com>
Subject: Re: [net-next PATCH 3/3] qdisc: sysctl to adjust bulk dequeue limit
Date: Tue, 2 Sep 2014 14:20:29 -0700
Message-ID: <CAHA+R7MT-HjOwit2pvkeWT2_pYHOupg=0YbTSTVJ8LbC+yhrDg@mail.gmail.com>
References: <20140902143254.1918.8419.stgit@dragon>
	<20140902143553.1918.73632.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Florian Westphal <fw@strlen.de>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Daniel Borkmann <dborkman@redhat.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:37614 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754848AbaIBVUa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 17:20:30 -0400
Received: by mail-la0-f45.google.com with SMTP id pn19so8637301lab.18
        for <netdev@vger.kernel.org>; Tue, 02 Sep 2014 14:20:29 -0700 (PDT)
In-Reply-To: <20140902143553.1918.73632.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 2, 2014 at 7:36 AM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:
> Allow userspace to adjust how many packet the qdisc is allowed to
> bulk dequeue.
>
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
>
> ---
> Question should we allow this to be adjusted?
>

A sysctl is ugly and seems not fit well with Qdisc which always uses netlink,
so I think a netlink flag might be better if we can find a generic one.

Also, you forgot to document it.
