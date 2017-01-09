From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH 1/3] Revert "icmp: avoid allocating large
 struct on stack"
Date: Mon, 09 Jan 2017 10:07:04 -0800
Message-ID: <1483985224.21472.3.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170109150246.30215.63371.stgit@firesoul>
         <20170109150404.30215.44512.stgit@firesoul>
         <CAM_iQpUNmaBx6L4CcrXkh6aFj-fEXdoGTBJt+33W3Xg-=7yhWA@mail.gmail.com>
         <1483984208.5846.9.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpV6YQ6nh_Y0f3BDgMheOic3bPiqQ1oNHR+saxxE7nBuoA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35740 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S970341AbdAISHF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 13:07:05 -0500
Received: by mail-pg0-f67.google.com with SMTP id 204so5505783pge.2
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2017 10:07:05 -0800 (PST)
In-Reply-To: <CAM_iQpV6YQ6nh_Y0f3BDgMheOic3bPiqQ1oNHR+saxxE7nBuoA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-01-09 at 09:59 -0800, Cong Wang wrote:
> On Mon, Jan 9, 2017 at 9:50 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Mon, 2017-01-09 at 09:42 -0800, Cong Wang wrote:
> >> On Mon, Jan 9, 2017 at 7:04 AM, Jesper Dangaard Brouer
> >> <brouer@redhat.com> wrote:
> >> > This reverts commit 9a99d4a50cb8 ("icmp: avoid allocating large struct
> >> > on stack"), because struct icmp_bxm no really a large struct, and
> >> > allocating and free of this small 112 bytes hurts performance.
> >>
> >> The original commit fixes a warning for large stack usage, icmp_send()
> >> is deep in the call stack.
> >>
> >> Your optimization for a slow path makes no sense to me.
> >
> > Do you have the stack trace of this event ?
> >
> > Even Linus allowed vmalloc() kernel stacks, while it certainly was an
> > heresy 10 years ago.
> >
> > I doubt it makes a difference trying to save 104 bytes of kernel stack.
> 
> I think you should have known this, quote from Eric Dumazet
> (hopefully the same one):
> 
>     On Fri, 2013-05-31 at 22:22 -0700, Eric Dumazet wrote:
> 
>     Strange, I posted a patch like that some days ago.
> 
> which is from: https://patchwork.ozlabs.org/patch/248051/
> 
> Facepalm...


We are in 2017.  Whatever was said in 2013 is irrelevant.

You really should come to netdev conferences so that you understand
goals and efforts, instead of living in your cave.

Then you can slap me in the face, since this is obviously your desire.

Then, we will drink a beer and relax.
