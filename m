From: Jack Morgenstein <jackm@dev.mellanox.co.il>
Subject: Re: [PATCH] net, mellanox mlx4 Fix compile warnings
Date: Sun, 15 Sep 2013 09:14:00 +0300
Message-ID: <20130915091400.49f90bc4@jpm-OptiPlex-GX620>
References: <1379075438-20240-1-git-send-email-prarit@redhat.com>
	<CAJZOPZLt8G8MsPxiRNySex=izThR74bXcnWTmWB2wjPys09_ig@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Prarit Bhargava <prarit@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Doug Ledford <dledford@redhat.com>,
	Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:38949 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752388Ab3IOGN6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Sep 2013 02:13:58 -0400
Received: by mail-we0-f174.google.com with SMTP id q58so2499782wes.19
        for <netdev@vger.kernel.org>; Sat, 14 Sep 2013 23:13:57 -0700 (PDT)
In-Reply-To: <CAJZOPZLt8G8MsPxiRNySex=izThR74bXcnWTmWB2wjPys09_ig@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 14 Sep 2013 22:10:19 +0300
Or Gerlitz <or.gerlitz@gmail.com> wrote:

> > +       struct res_cq *uninitialized_var(cq);
> >
> >         err = cq_res_start_move_to(dev, slave, cqn,
> > RES_CQ_ALLOCATED, &cq);

I have no objection. However, I don't know if the compiler is being too
clever here or too stupid.  The cq variable is initialized in
cq_res_start_move_to(), but the compiler is ignoring this -- or maybe
it is simply not assuming that cq will in fact be
initialized by the called procedure?

In any event, this change cannot hurt.

-Jack 
