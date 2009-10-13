From: Rakib Mullick <rakib.mullick@gmail.com>
Subject: Re: [PATCH -mm] connector: Passing required parameter for function
	cn_add_callback.
Date: Tue, 13 Oct 2009 13:00:18 +0600
Message-ID: <b9df5fa10910130000k20f53a4pfc3593db95c66138@mail.gmail.com>
References: <b9df5fa10910111944s274207aica39c0e646c10f7a@mail.gmail.com>
	 <20091011.223502.77690228.davem@davemloft.net>
	 <b9df5fa10910122227r710d6782m89fc9ec4273487b8@mail.gmail.com>
	 <20091012.234214.110950674.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, zbr@ioremap.net,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f187.google.com ([209.85.216.187]:39662 "EHLO
	mail-px0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933333AbZJMHAz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 03:00:55 -0400
In-Reply-To: <20091012.234214.110950674.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/13/09, David Miller <davem@davemloft.net> wrote:
> From: Rakib Mullick <rakib.mullick@gmail.com>
>
> Date: Tue, 13 Oct 2009 11:27:49 +0600
>
>
>  > On 10/12/09, David Miller <davem@davemloft.net> wrote:
>  >> From: Rakib Mullick <rakib.mullick@gmail.com>
>  >>  Date: Mon, 12 Oct 2009 08:44:33 +0600
>  >>
>  >>
>  >>  >   */
>  >>  > -static void cn_proc_mcast_ctl(struct cn_msg *msg)
>  >>  > +static void cn_proc_mcast_ctl(struct cn_msg *msg, struct
>  >>  > netlink_skb_parms *nsp)
>  >>
>  >>
>  >> Your patches are unusable because your email client corrupts the
>  >>  patch, here you can see it is splitting up long lines.
>  >>
>  >>  Please fix this up and resubmit.
>  > Oops..... sorry for that. This is the second time I'm facing this
>  > problem. I'll try to fix it.
>  > I'm resubmitting the patch. Here I've recreate the patch to split the
>  > line into two.
>  > And it just reaches its 80 line mark. Hopefully it will be okay.
>
>
> Upstream and my net-next-2.6 tree both have this function with
>  the proper parameters, maybe Andrew's -mm tree had some conflicts
>  and they weren't dealt with correctly.
>
Ah, sorry again. I should've check the upstream first. Sorry for noise.

Thanks,
