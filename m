From: Richard Guy Briggs <rgb@redhat.com>
Subject: Re: netlink: GPF in sock_sndtimeo
Date: Tue, 29 Nov 2016 23:52:07 -0500
Message-ID: <20161130045207.GE26673@madcap2.tricolour.ca>
References: <20161129164859.GD26673@madcap2.tricolour.ca>
 <CAM_iQpX_KBEpL1dCBNMgZQ-VQJM9nmsVdRPVK-Aen9k0gV3f0w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dmitry Vyukov <dvyukov@google.com>,
        David Miller <davem@davemloft.net>,
        Johannes Berg <johannes.berg@intel.com>,
        Florian Westphal <fw@strlen.de>,
        Eric Dumazet <edumazet@google.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60134 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752344AbcK3EwM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 29 Nov 2016 23:52:12 -0500
Content-Disposition: inline
In-Reply-To: <CAM_iQpX_KBEpL1dCBNMgZQ-VQJM9nmsVdRPVK-Aen9k0gV3f0w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016-11-29 15:13, Cong Wang wrote:
> On Tue, Nov 29, 2016 at 8:48 AM, Richard Guy Briggs <rgb@redhat.com> wrote:
> > On 2016-11-26 17:11, Cong Wang wrote:
> >> It is racy on audit_sock, especially on the netns exit path.
> >
> > I think that is the only place it is racy.  The other places audit_sock
> > is set is when the socket failure has just triggered a reset.
> >
> > Is there a notifier callback for failed or reaped sockets?
> 
> Is NETLINK_URELEASE event what you are looking for?

Possibly, yes.  Thanks, I'll have a look.

- RGB
