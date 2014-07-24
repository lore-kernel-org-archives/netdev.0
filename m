From: Cong Wang <cwang@twopensource.com>
Subject: Re: Please queue some netns bug fixes for stable
Date: Thu, 24 Jul 2014 14:21:13 -0700
Message-ID: <CAHA+R7N=fkuWDaSMhK9hakWD_ONLJo9daqd_DfrEdGjYq=Wx0w@mail.gmail.com>
References: <CAHA+R7MRazPQzcJdPr0UC3KtJUP4xHwqy9ysrP3a=QXFf74zoQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:57011 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759443AbaGXVVP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2014 17:21:15 -0400
Received: by mail-lb0-f171.google.com with SMTP id l4so2772235lbv.30
        for <netdev@vger.kernel.org>; Thu, 24 Jul 2014 14:21:13 -0700 (PDT)
In-Reply-To: <CAHA+R7MRazPQzcJdPr0UC3KtJUP4xHwqy9ysrP3a=QXFf74zoQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 27, 2014 at 4:17 PM, Cong Wang <cwang@twopensource.com> wrote:
> Hi, David
>
>
> Please queue the following commits for -stable, all kernels < 3.12.
>
> You backported the last one (from me) to 3.14 and 3.12, but for kernels < 3.12
> we probably need all of these three:
>
> commit 50624c934db18ab90aaea4908f60dd39aab4e6e5
> Author: Eric W. Biederman <ebiederm@xmission.com>
> Date:   Mon Sep 23 21:19:49 2013 -0700
>
>     net: Delay default_device_exit_batch until no devices are unregistering v2
>
> commit 5cde282938915f36a2e6769b51c24c4159654859
> Author: Eric W. Biederman <ebiederm@xmission.com>
> Date:   Sat Oct 5 19:26:05 2013 -0700
>
>     net: Separate the close_list and the unreg_list v2
>
> commit 200b916f3575bdf11609cb447661b8d5957b0bbf
> Author: Cong Wang <cwang@twopensource.com>
> Date:   Mon May 12 15:11:20 2014 -0700
>
>     rtnetlink: wait for unregistering devices in rtnl_link_unregister()
>
>
> AFAIK, all 3.x kernels are affected. Eric should know better than me here.
>

David, any response? We are still waiting for you to send them to stable. :)

Thanks!
