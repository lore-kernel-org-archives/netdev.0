From: Luiz Augusto von Dentz <luiz.dentz@gmail.com>
Subject: Re: [PATCH 0/10] af_unix: add multicast and filtering features to AF_UNIX
Date: Fri, 2 Mar 2012 12:08:11 +0200
Message-ID: <CABBYNZJWKGpkK2mSbGCQ2KkE+jC3ih-wR3JQZSMgj7AYhbxeuw@mail.gmail.com>
References: <CABBYNZJ-xxQXAx+ecrkVLqmWFaUVqLcQLj0Jxa3McSLnkLJSJw@mail.gmail.com>
	<20120301.170848.432407217191581288.davem@davemloft.net>
	<CABBYNZLwHKd5srzYYzWNL-iaeuH1K31824pY_bjRSbSLkv0QtA@mail.gmail.com>
	<20120302.035509.1994457175982020283.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: eric.dumazet@gmail.com, javier.martinez@collabora.co.uk,
	rodrigo.moya@collabora.co.uk, javier@collabora.co.uk,
	lennart@poettering.net, kay.sievers@vrfy.org,
	alban.crequy@collabora.co.uk, bart.cerneels@collabora.co.uk,
	sjoerd.simons@collabora.co.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120302.035509.1994457175982020283.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

On Fri, Mar 2, 2012 at 10:55 AM, David Miller <davem@davemloft.net> wrote:
> From: Luiz Augusto von Dentz <luiz.dentz@gmail.com>
> Date: Fri, 2 Mar 2012 10:39:24 +0200
>
>> Like I said before there is many projects using AF_UNIX as IPC
>> transport, the documentation actually induces people to use for this
>> purpose, and many would benefit from being able to do multicast.
>
> You can't have it both ways.
>
> If it's useful for many applications, then many applications would
> benefit from a userland library that solved the problem using
> existing facilities such as IP multicast.
>
> If it's only useful for dbus that that absoltely means we should
> not add thousands of lines of code to the kernel specifically for
> that application.

Instead we should add many times that into dbus-daemon and do IP
multicast, am I missing something?

> So either way, kernel changes are not justified.

I respect your opinion, but I don't agree with it, you are pushing
userspace to a much more complex solution.

At this point it would probably better to just use shared memory and
forget about any security, eavesdrop all the way.

-- 
Luiz Augusto von Dentz
