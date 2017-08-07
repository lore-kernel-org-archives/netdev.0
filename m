From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC] iproute: Add support for extended ack to rtnl_talk
Date: Mon, 7 Aug 2017 11:06:49 -0700
Message-ID: <20170807110649.052e028a@xeon-e3>
References: <590AF624.6090808@iogearbox.net>
        <7315b681-9c78-4bc1-ab74-64509ab5887d@gmail.com>
        <20170504.104103.1628291573330660235.davem@davemloft.net>
        <20170504094356.66590a9a@xeon-e3>
        <20170504204318.GB21130@orbyte.nwl.cc>
        <f847c8d4-a6c0-66ab-0ac0-d83d6ea96a00@gmail.com>
        <20170516093625.178caf3f@xeon-e3>
        <591D711F.1000906@iogearbox.net>
        <1c494983-24e0-cd8f-9a2a-5d2a83e0bbc2@gmail.com>
        <0d84bd27-2fd1-68c0-5787-0195e95ab1af@gmail.com>
        <20170804113147.GA25254@vergenet.net>
        <20170804094729.00548085@xeon-e3>
        <8e8bc709-55b0-e207-b4bf-605bdf2ba323@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Simon Horman <simon.horman@netronome.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Phil Sutter <phil@nwl.cc>, David Miller <davem@davemloft.net>,
        netdev@vger.kernel.org
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:33287 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751800AbdHGSGw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 14:06:52 -0400
Received: by mail-pg0-f50.google.com with SMTP id u5so4599816pgn.0
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 11:06:52 -0700 (PDT)
In-Reply-To: <8e8bc709-55b0-e207-b4bf-605bdf2ba323@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 7 Aug 2017 10:48:23 -0600
David Ahern <dsahern@gmail.com> wrote:

> On 8/4/17 10:47 AM, Stephen Hemminger wrote:
> > I will put in the libmnl version. If it doesn't work because no one sent
> > me test cases, then fine. send a patch for that.  
> 
> This commit:
> 
> commit b6432e68ac2f1f6b4ea50aa0d6d47e72c445c71c
> Author: Stephen Hemminger <stephen@networkplumber.org>
> Date:   Fri Aug 4 09:52:15 2017 -0700
> 
>     iproute: Add support for extended ack to rtnl_talk
> 
> 
> Does not work. Seems like you pushed the RFC commit which was known to
> be incomplete.

Patches welcome.

> First, the Config is HAVE_MNL not HAVE_LIBMNL which is in lib/libnetlink.c.
> 
> Second, changing that to HAVE_MNL does not work -- something is not
> getting passed in correctly. Just remove the semicolon on the else path:
> 
> +#else
> +/* No extended error ack without libmnl */
> +static int nl_dump_ext_err(const struct nlmsghdr *nlh, nl_ext_ack_fn_t
> errfn)
> +{
> +       return 0;
> +}
> +#endif
> 
> and you will see that HAVE_MNL is never defined.

Ok, that I will fix.
