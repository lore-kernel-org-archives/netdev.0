From: Daniel Baluta <daniel.baluta@gmail.com>
Subject: Re: [PATCH net-next v2] tcp: bind() use stronger condition for bind_conflict
Date: Fri, 13 Apr 2012 09:12:15 +0300
Message-ID: <CAEnQRZAqpW79z4Pcg6zJP1AmSaXSaf7a-aTxjZfL7cYHbCO7ag@mail.gmail.com>
References: <1333698444-24144-1-git-send-email-alex.mihai.c@gmail.com>
	<CAEnQRZALcP8AOOPzu0_Nn+FGbTDu_geSj-AzGNe39E4GHitFSQ@mail.gmail.com>
	<1334296413.5300.8416.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: alex.mihai.c@gmail.com, davem@davemloft.net, fbl@redhat.com,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:62245 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752768Ab2DMGMP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2012 02:12:15 -0400
Received: by obbta14 with SMTP id ta14so199188obb.19
        for <netdev@vger.kernel.org>; Thu, 12 Apr 2012 23:12:15 -0700 (PDT)
In-Reply-To: <1334296413.5300.8416.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 13, 2012 at 8:53 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2012-04-13 at 08:36 +0300, Daniel Baluta wrote:
>
>> Eric, David can you have a look on this?
>
>
> Hi Daniel
>
> I can, but can you provide me the sources of the tests you ran ?
>
> (I am kind of busy these days)

Sure. You can find the sources here [1].
* prepare-test.sh, sets up 100 interfaces.
* ./testcon -c <connections> -i <ips>, runs the test.

The results shown in patch description are obtained as follows:

* 60000 sockets, 600 ports / IP:
** ./testcon -c 60000 -i 100
* 100000 sockets, 1000 ports / IP:
** ./testcon -c 100000 -i 100
* 200000 sockets, 2000 ports / IP:
** ./testcon -c 200000 -i 100
* 500000 sockets, 5000 ports / IP:
** ./testcon -c 500000 -i 100

thanks,
Daniel.

[1] http://ixlabs.cs.pub.ro/gitweb/?p=port-allocation.git;a=tree;f=testbind;hb=master
