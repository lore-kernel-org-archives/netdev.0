From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [PATCH 4/5] VSOCK: add sock_diag interface
Date: Wed, 4 Oct 2017 11:05:03 -0400
Message-ID: <20171004150503.GC3840@stefanha-x1.localdomain>
References: <20171003153943.23159-1-stefanha@redhat.com>
 <20171003153943.23159-5-stefanha@redhat.com>
 <20171003.214652.1920235341803755309.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jhansen@vmware.com, decui@microsoft.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56028 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752310AbdJDPFP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 4 Oct 2017 11:05:15 -0400
Content-Disposition: inline
In-Reply-To: <20171003.214652.1920235341803755309.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 03, 2017 at 09:46:52PM -0700, David Miller wrote:
> From: Stefan Hajnoczi <stefanha@redhat.com>
> Date: Tue,  3 Oct 2017 11:39:42 -0400
> 
> > +static int sk_diag_fill(struct sock *sk, struct sk_buff *skb,
> > +			u32 portid, u32 seq, u32 flags)
> > +{
> > +	struct nlmsghdr *nlh;
> > +	struct vsock_diag_msg *rep;
> > +	struct vsock_sock *vsk = vsock_sk(sk);
> 
> Please order local variables from longest to shortest line.
> 
> > +static int vsock_diag_dump(struct sk_buff *skb, struct netlink_callback *cb)
> > +{
> > +	struct vsock_diag_req *req;
> > +	unsigned int table;
> > +	unsigned int bucket;
> > +	unsigned int last_i;
> > +	unsigned int i;
> > +	struct vsock_sock *vsk;
> > +	struct net *net;
> 
> Likewise.

Will fix in v2.
