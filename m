From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: Re: [PATCH net-next v2 2/2] vxlan: allow specifying multiple default destinations
Date: Tue, 28 May 2013 11:58:11 +0300
Message-ID: <CAF1J0HNvMUCLAYUwdbkZRen-YQxwVSsSbzMhvWdbOfwt24dqAQ@mail.gmail.com>
References: <1369729878-9690-1-git-send-email-mike.rapoport@ravellosystems.com>
	<1369729878-9690-3-git-send-email-mike.rapoport@ravellosystems.com>
	<ko1qss$gu8$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog113.obsmtp.com ([74.125.245.94]:48095 "HELO
	na3sys010aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S933624Ab3E1I6N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 04:58:13 -0400
Received: by mail-ob0-f178.google.com with SMTP id fb19so1505710obc.37
        for <netdev@vger.kernel.org>; Tue, 28 May 2013 01:58:11 -0700 (PDT)
In-Reply-To: <ko1qss$gu8$1@ger.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 28, 2013 at 11:46 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>
> On Tue, 28 May 2013 at 08:31 GMT, Mike Rapoport <mike.rapoport@ravellosystems.com> wrote:
> > +     IFLA_VXLAN_REMOTE_ADD,
> > +     IFLA_VXLAN_REMOTE_DEL,
> > +     IFLA_VXLAN_REMOTE_LST,
>
> Usually we use NEW_* and GET_* instead of *_ADD and *_LST.

Semantically ADD and LST seem more correct to me. We are adding a
destination and asking for destinations list...

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html




--
Sincerely yours,
Mike.
