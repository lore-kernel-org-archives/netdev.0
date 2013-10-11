From: Kyle Hubert <khubert@gmail.com>
Subject: Re: Peak TCP performance
Date: Fri, 11 Oct 2013 00:21:36 -0400
Message-ID: <CAJoZ4U2CRaF+kvgXhbq3DNkMdYbouoKdU-xAUAkuhD5LbC7X8Q@mail.gmail.com>
References: <CAJoZ4U2eVUd4JiGQ6UFYMdoEwyN=MO8+9S3jGcsaYGN2vqt=3g@mail.gmail.com>
	<1381461664.4971.97.camel@edumazet-glaptop.roam.corp.google.com>
	<CAJoZ4U0tpKhknMLd7kN4uQmq-E81=EbH1Q816nX_eig=tGreAQ@mail.gmail.com>
	<1381463075.4971.99.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f51.google.com ([209.85.128.51]:57744 "EHLO
	mail-qe0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751040Ab3JKEVh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Oct 2013 00:21:37 -0400
Received: by mail-qe0-f51.google.com with SMTP id q19so2926227qeb.10
        for <netdev@vger.kernel.org>; Thu, 10 Oct 2013 21:21:36 -0700 (PDT)
In-Reply-To: <1381463075.4971.99.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 10, 2013 at 11:44 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> Also, my copy of ethtool does not recognize tx-nocache-copy. However,
>> I do have control over the net device. Is there something there I can
>> set, or is tx-nocache-copy also a new feature? I'll start digging.
>>
>
> nocache-copy was added in 3.0, but I do find its not a gain for current
> cpus.
>
> You could get a fresh copy of ethtool sources :
>
> git clone git://git.kernel.org/pub/scm/network/ethtool/ethtool.git
> cd ethtool
> ./autogen.sh  ...

That did the trick. Thanks for the help! Is there somewhere I can read
up on this feature? A lot of the netdev features are opaque to me.
Also, I can set NETIF_F_NOCACHE_COPY in the netdev->features to set
this by default, yes?

This at least mirrors the performance improvement that I see when
forwarding, however I still see reserved CPU time. Is there a way to
push it even farther?

-Kyle
