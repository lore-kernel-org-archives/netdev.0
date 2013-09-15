From: ZHAO Gang <gamerh2o@gmail.com>
Subject: Re: [PATCH] net, mellanox mlx4 Fix compile warnings
Date: Sun, 15 Sep 2013 14:22:23 +0800
Message-ID: <20130915062125.GA20185@will>
References: <1379075438-20240-1-git-send-email-prarit@redhat.com>
 <CAJZOPZLt8G8MsPxiRNySex=izThR74bXcnWTmWB2wjPys09_ig@mail.gmail.com>
 <20130915091400.49f90bc4@jpm-OptiPlex-GX620>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Or Gerlitz <or.gerlitz@gmail.com>,
	Prarit Bhargava <prarit@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Doug Ledford <dledford@redhat.com>,
	Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: gamerh2o@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:60517 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753111Ab3IOGWs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Sep 2013 02:22:48 -0400
Received: by mail-pb0-f49.google.com with SMTP id xb4so2817984pbc.36
        for <netdev@vger.kernel.org>; Sat, 14 Sep 2013 23:22:47 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20130915091400.49f90bc4@jpm-OptiPlex-GX620>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hell what!

On Sun, Sep 15, 2013 at 09:14:00AM +0300, Jack Morgenstein wrote:
> On Sat, 14 Sep 2013 22:10:19 +0300
> Or Gerlitz <or.gerlitz@gmail.com> wrote:
> 
> > > +       struct res_cq *uninitialized_var(cq);
> > >
> > >         err = cq_res_start_move_to(dev, slave, cqn,
> > > RES_CQ_ALLOCATED, &cq);
> 
> I have no objection. However, I don't know if the compiler is being too
> clever here or too stupid.  The cq variable is initialized in
> cq_res_start_move_to(), but the compiler is ignoring this -- or maybe
> it is simply not assuming that cq will in fact be
> initialized by the called procedure?
> 
> In any event, this change cannot hurt.
> 
> -Jack 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
