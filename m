From: ZHAO Gang <gamerh2o@gmail.com>
Subject: Re: [PATCH] net, mellanox mlx4 Fix compile warnings
Date: Sun, 15 Sep 2013 14:27:36 +0800
Message-ID: <CAAb+SYab27uo7vF40++7knVVO_mEz+LKQKAiL5c-mKVeeJHUjQ@mail.gmail.com>
References: <1379075438-20240-1-git-send-email-prarit@redhat.com>
	<CAJZOPZLt8G8MsPxiRNySex=izThR74bXcnWTmWB2wjPys09_ig@mail.gmail.com>
	<20130915091400.49f90bc4@jpm-OptiPlex-GX620>
	<20130915062125.GA20185@will>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <or.gerlitz@gmail.com>,
	Prarit Bhargava <prarit@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Doug Ledford <dledford@redhat.com>,
	Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: ZHAO Gang <gamerh2o@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:59755 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752524Ab3IOG1h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Sep 2013 02:27:37 -0400
Received: by mail-pd0-f175.google.com with SMTP id q10so2868969pdj.34
        for <netdev@vger.kernel.org>; Sat, 14 Sep 2013 23:27:36 -0700 (PDT)
In-Reply-To: <20130915062125.GA20185@will>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sorry for the inconvenince, i'm just practise the use of mutt, sorry again.

On Sun, Sep 15, 2013 at 2:22 PM, ZHAO Gang <gamerh2o@gmail.com> wrote:
> hell what!
>
> On Sun, Sep 15, 2013 at 09:14:00AM +0300, Jack Morgenstein wrote:
>> On Sat, 14 Sep 2013 22:10:19 +0300
>> Or Gerlitz <or.gerlitz@gmail.com> wrote:
>>
>> > > +       struct res_cq *uninitialized_var(cq);
>> > >
>> > >         err = cq_res_start_move_to(dev, slave, cqn,
>> > > RES_CQ_ALLOCATED, &cq);
>>
>> I have no objection. However, I don't know if the compiler is being too
>> clever here or too stupid.  The cq variable is initialized in
>> cq_res_start_move_to(), but the compiler is ignoring this -- or maybe
>> it is simply not assuming that cq will in fact be
>> initialized by the called procedure?
>>
>> In any event, this change cannot hurt.
>>
>> -Jack
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
