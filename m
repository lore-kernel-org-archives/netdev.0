From: Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] IB/IPoIB: Check the headroom size
Date: Wed, 26 Apr 2017 00:50:06 +0300
Message-ID: <CAJ3xEMjqkJrKi+6ronuPBn2P6y8p6sdhVppDzFtMwQrhL13bzg@mail.gmail.com>
References: <1493114155-12101-1-git-send-email-honli@redhat.com>
 <CAJ3xEMg4_2ph7QwPsUb-tX-K4d2ppkqz98sPzytsmBCK=29WHw@mail.gmail.com>
 <CAAk-MO8O19iC2Yn-BMn5pKTAYxaSzGPMyta=fwes3XSvzmz_cQ@mail.gmail.com>
 <CAJ3xEMgw=9sj3rdahPEiST_yDfDJPNSZZLRn43tnb3bK4_RPzg@mail.gmail.com>
 <CAAk-MO-B8Liv6RyGye_Fx-9OELCUrGMj5SwK9UsciC=khSO5fA@mail.gmail.com>
 <CAJ3xEMgwS1Bq8+eZC1iAr6xi8ZPHrchsOJ5r4LNJxR8P+6VipA@mail.gmail.com> <1493134815.3041.72.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Erez Shitrit <erezsh-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>,
        Paolo Abeni <pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Honggang LI <honli-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1493134815.3041.72.camel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 25, 2017 at 6:40 PM, Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> On Tue, 2017-04-25 at 17:39 +0300, Or Gerlitz wrote:

>> If got you right, Paolo's commit introduced a regression, so we (I
>> guess you and Paolo) need to either solve it or we (community)
>> should consider a revert, please suggest.

> [...] So, this issue should be
> reproducible either after Paolo's commit or with any kernel prior to
> your commit to use the skb->cb area to store the DGID, but it probably
> requires the specific series of actions in this bug to trigger it.

mmm

> A normal, clean shutdown of the interface doesn't demonstrate the issue.

so maybe @ least for the time being, we should be picking Hong's patch
with proper change log and without the giant stack dump till we have
something better. If you agree, can you do the re-write of the change
log?

Or.


>> The bug is now in stable and distro kernels, so please act.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
