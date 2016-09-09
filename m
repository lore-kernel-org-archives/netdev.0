From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH v4 2/4] wcn36xx: Transition driver to SMD client
Date: Fri, 09 Sep 2016 08:17:09 +0300
Message-ID: <87inu5r6sq.fsf@kamboji.qca.qualcomm.com>
References: <1473200312-22438-1-git-send-email-bjorn.andersson@linaro.org>
        <1473200312-22438-2-git-send-email-bjorn.andersson@linaro.org>
        <87k2emsi22.fsf@kamboji.qca.qualcomm.com>
        <CAOCOHw5Wvy5g0HuDaYUZ2WTCws5uXtw6DO7S3Dvp+0mgW-Mg=Q@mail.gmail.com>
        <878tv2s3ao.fsf@kamboji.qca.qualcomm.com>
        <20160909042159.GD405@tuxbot>
        <20160909042754.GA32071@hector.attlocal.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bjorn Andersson <bjorn.andersson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        Eugene Krasnikov <k.eugene.e-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        wcn36xx-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        linux-arm-msm <linux-arm-msm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Andy Gross <andy.gross-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160909042754.GA32071-3KkwrOJo9xYlRp7syxWybdHuzzzSOjJt@public.gmane.org> (Andy Gross's
        message of "Thu, 8 Sep 2016 23:27:54 -0500")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Andy Gross <andy.gross-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org> writes:

>> > >> This doesn't compile for me:
>> > >>
>> > >
>> > > I thought I mentioned this in the mail, sorry for missing that.
>> > 
>> > Maybe you did and I just forgot, I have a tendency to do that :)
>> > 
>> > > There is a patch for this issue in linux-next already [1] which is
>> > > part of [2], which was part of the pull request to arm-soc for
>> > > inclusion in v4.9.
>> > >
>> > > [1] https://patchwork.kernel.org/patch/9272457/
>> > > [2] https://git.kernel.org/cgit/linux/kernel/git/agross/linux.git/tag/?h=qcom-drivers-for-4.9
>> > 
>> > So the commit in question is:
>> > 
>> > soc: qcom: smd: Correct compile stub prototypes
>> > https://git.kernel.org/cgit/linux/kernel/git/agross/linux.git/commit/?h=qcom-drivers-for-4.9&id=3a1281848830fcb3202cfd7ffe62d19641471d05
>> > 
>> 
>> Correct
>> 
>> > But that's not obviously in my tree yet, but I should have it after
>> > 4.9-rc1 is released. I think it's easiest that I wait for that before
>> > applying these. Do you agree?
>> > 
>> 
>> Would be nice to have it land sooner rather than later, but I'm okay
>> with this.
>
> We could just treat the tag as immutable.  You can merge the tag in and arm-soc
> can as well.  it'll just get nop'd the second time it is taken.  The only
> downside is if arm-soc doesn't take my merge request.

I take it that you are talking about this tag:

git://git.kernel.org/pub/scm/linux/kernel/git/agross/linux.git qcom-drivers-for-4.9

I did a test pull and there are only 8 commits so in theory that could
work. But my trees go via Dave Miller's net-next so I can't control when
they hit Linus' tree. It might be that Linus pulls the net-next tree
before arm-soc and arm-soc commits coming from net-next might confuse
people. I'm just afraid that the hassle would outweight the benefit.

> Or we can wait till -rc1

To keep things simple I prefer this option. Of course it means waiting
few more extra weeks, but when working with new subsystems that can
happen. The crystall ball[1] says that 4.9-rc1 would be released on
2016-10-16 so it's not that far away.

[1] http://phb-crystal-ball.org/

-- 
Kalle Valo
