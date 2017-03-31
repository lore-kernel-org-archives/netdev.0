From: "Gao Feng" <gfree.wind@foxmail.com>
Subject: RE: [PATCH nf-next 1/1] net: tcp: Refine the __tcp_select_window
Date: Fri, 31 Mar 2017 09:11:58 +0800
Message-ID: <000601d2a9bb$cc4e2ea0$64ea8be0$@foxmail.com>
References: <1490827759-12142-1-git-send-email-gfree.wind@foxmail.com> <20170330.154210.2218850010642353664.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
        charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>,
        <netdev@vger.kernel.org>, <fgao@ikuai8.com>
To: "'David Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbguseast2.qq.com ([54.204.34.130]:40596 "EHLO
        smtpbguseast2.qq.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934642AbdCaBMK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 30 Mar 2017 21:12:10 -0400
In-Reply-To: <20170330.154210.2218850010642353664.davem@davemloft.net>
Content-Language: zh-cn
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of David Miller
> Sent: Friday, March 31, 2017 6:42 AM
> To: gfree.wind@foxmail.com
> Cc: kuznet@ms2.inr.ac.ru; jmorris@namei.org; netdev@vger.kernel.org;
> fgao@ikuai8.com
> Subject: Re: [PATCH nf-next 1/1] net: tcp: Refine the __tcp_select_window
> 
> From: gfree.wind@foxmail.com
> Date: Thu, 30 Mar 2017 06:49:19 +0800
> 
> > From: Gao Feng <fgao@ikuai8.com>
> >
> > 1. Move the "window = tp->rcv_wnd;" into the condition block without
> > tp->rx_opt.rcv_wscale.
> > Because it is unnecessary when enable wscale;
> >
> > 2. Use the macro ALIGN instead of two statements.
> > The two statements are used to make window align to 1<<wscale.
> > Use the ALIGN is more clearer.
> >
> > 3. Use the rounddown to make codes clearer.
> >
> > Signed-off-by: Gao Feng <fgao@ikuai8.com>
> 
> Applied, but please do not target non-netfilter patches using "nf-next" in
your
> Subject lines.

Sorry, I misspelled the subject.
I would pay more attention on it.

Regards
Feng
