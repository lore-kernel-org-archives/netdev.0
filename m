From: Tom Herbert <therbert@google.com>
Subject: Re: [net-next PATCH 3/3] qdisc: sysctl to adjust bulk dequeue limit
Date: Tue, 2 Sep 2014 17:12:03 -0700
Message-ID: <CA+mtBx_GSvXNY3wgbu25Kb5ZZsqMUb9thdiqg4AL-Q6EMGPV5w@mail.gmail.com>
References: <20140902143254.1918.8419.stgit@dragon>
	<20140902143553.1918.73632.stgit@dragon>
	<CAHA+R7MT-HjOwit2pvkeWT2_pYHOupg=0YbTSTVJ8LbC+yhrDg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Florian Westphal <fw@strlen.de>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Daniel Borkmann <dborkman@redhat.com>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:47274 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753749AbaICAME (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 20:12:04 -0400
Received: by mail-ig0-f177.google.com with SMTP id r10so8205372igi.4
        for <netdev@vger.kernel.org>; Tue, 02 Sep 2014 17:12:03 -0700 (PDT)
In-Reply-To: <CAHA+R7MT-HjOwit2pvkeWT2_pYHOupg=0YbTSTVJ8LbC+yhrDg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 2, 2014 at 2:20 PM, Cong Wang <cwang@twopensource.com> wrote:
>
> On Tue, Sep 2, 2014 at 7:36 AM, Jesper Dangaard Brouer
> <brouer@redhat.com> wrote:
> > Allow userspace to adjust how many packet the qdisc is allowed to
> > bulk dequeue.
> >
> > Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> >
> > ---
> > Question should we allow this to be adjusted?
> >
>
> A sysctl is ugly and seems not fit well with Qdisc which always uses netlink,
> so I think a netlink flag might be better if we can find a generic one.
>
You could also make this a device specific attribute easily enough.

> Also, you forgot to document it.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
