From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH next v0] bonding: Display LACP info only to CAP_SYS_ADMIN
 capable user
Date: Fri, 12 Jun 2015 10:53:02 -0700
Message-ID: <CAF2d9jgv-tmvvOHGmoyEYSmB5v-Bn93-T8kjMUk51miKSomECA@mail.gmail.com>
References: <1433981996-6010-1-git-send-email-maheshb@google.com> <20150611.152257.1284649637451689093.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: j.vosburgh@gmail.com, andy@greyhouse.net, vfalico@gmail.com,
	nikolay@redhat.com, linux-netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	=?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:33723 "EHLO
	mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750861AbbFLRxX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jun 2015 13:53:23 -0400
Received: by oiha141 with SMTP id a141so26092840oih.0
        for <netdev@vger.kernel.org>; Fri, 12 Jun 2015 10:53:23 -0700 (PDT)
In-Reply-To: <20150611.152257.1284649637451689093.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 11, 2015 at 3:22 PM, David Miller <davem@davemloft.net> wrote:
>
> From: Mahesh Bandewar <maheshb@google.com>
> Date: Wed, 10 Jun 2015 17:19:56 -0700
>
> > Actor and Partner details can be accessed via proc-fs and sys-fs
> > entries. These interfaces are world readable at this moment. The
> > earlier patch-series made the LACP communication secure to avoid
> > nuisance attack from within the same L2 domain but it did not
> > prevent "someone unprivileged" looking at that information on host
> > and perform the same act.
> >
> > This patch essentially avoids spitting those entries if the user
> > in question does not have enough privileges.
> >
> > Signed-off-by: Mahesh Bandewar <maheshb@google.com>
>
> I agree with Stephen Hemminger in that you should probably be using
> CAP_NET_ADMIN here.
Will change that into the next revision.

Thanks,
--mahesh..
