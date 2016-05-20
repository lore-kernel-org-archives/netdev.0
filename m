From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net] fou: avoid using sk_user_data before it is
 initialised
Date: Fri, 20 May 2016 14:58:33 +0900
Message-ID: <20160520055828.GB14582@vergenet.net>
References: <1463560216-26616-1-git-send-email-simon.horman@netronome.com>
 <CALx6S35yHpUk2NQe+JAUYcY7mMBLWRuy75egsDCCB3dmhrC1Ng@mail.gmail.com>
 <CAM_iQpWJ1BXk9wSypFSacVbHtF2xUEscYByD=qp56rO_5bXAeA@mail.gmail.com>
 <CALx6S35_owy-0ani--u5H=jQ1PTAcNprbZWNh+QBmHVgCe98NQ@mail.gmail.com>
 <CAM_iQpW2TMHjch6F959LZ171HgeV5Bz-b2sCwtGde1Haw6PyPA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Herbert <tom@herbertland.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:33374 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752075AbcETF6m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2016 01:58:42 -0400
Received: by mail-pa0-f50.google.com with SMTP id xk12so36371739pac.0
        for <netdev@vger.kernel.org>; Thu, 19 May 2016 22:58:42 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAM_iQpW2TMHjch6F959LZ171HgeV5Bz-b2sCwtGde1Haw6PyPA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 19, 2016 at 10:17:40PM -0700, Cong Wang wrote:
> On Wed, May 18, 2016 at 10:16 AM, Tom Herbert <tom@herbertland.com> wrote:
> > On Wed, May 18, 2016 at 10:07 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> >> On Wed, May 18, 2016 at 9:30 AM, Tom Herbert <tom@herbertland.com> wrote:
> >>> On Wed, May 18, 2016 at 1:30 AM, Simon Horman
> >>> <simon.horman@netronome.com> wrote:
> >>>> During initialisation sk->sk_user_data should be initialised before
> >>>> it is referenced via a call to gue_encap_init().
> >>>>
> >>> I think this is should be fixed by proposed patch "fou:
> >>> Call-setup_udp_tunnel_sock".
> >>
> >> That is 6/16, do you have a fix for stable to backport?
> >
> > Your patch to use fou directly is good.
> 
> Note, I am waiting for Simon to update his patch if he agrees.

Thanks, I've sent an updated patch.

I'm also quite happy for it to be fixed another way if you prefer
e.g. by your own patch.
