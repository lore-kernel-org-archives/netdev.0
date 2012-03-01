From: Luiz Augusto von Dentz <luiz.dentz@gmail.com>
Subject: Re: [PATCH 0/10] af_unix: add multicast and filtering features to AF_UNIX
Date: Fri, 2 Mar 2012 00:01:40 +0200
Message-ID: <CABBYNZJ-xxQXAx+ecrkVLqmWFaUVqLcQLj0Jxa3McSLnkLJSJw@mail.gmail.com>
References: <20120228.140558.1132853996225815681.davem@davemloft.net>
	<4F4F641E.7000501@collabora.co.uk>
	<1330604802.2465.43.camel@edumazet-laptop>
	<20120301.154415.1692328508436381200.davem@davemloft.net>
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
In-Reply-To: <20120301.154415.1692328508436381200.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

On Thu, Mar 1, 2012 at 10:44 PM, David Miller <davem@davemloft.net> wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 01 Mar 2012 04:26:42 -0800
>
>> Why adding an obscure set of IPC mechanism in network tree, and not
>> using (maybe extending) traditional IPC (Messages queues, semaphores,
>> Shared memory, pipes, futexes, ...).
>
> I actually don't understand why there is so much resistence to using a
> real bonafide on-the-wire protocol, and that way if you ever wanted to
> connect dbus instances on multiple machines or log dbus transactions
> remotely for debugging, you could just do it.

I don't think you understood the problem, we want something that scale
for less powerful devices, why do you think Android have all the
trouble to create binder?

Besides what is really the point in having AF_UNIX if you can't use
for what it is for?

"The  AF_UNIX (also known as AF_LOCAL) socket family is used to
communicate between processes on the same machine efficiently."

-- 
Luiz Augusto von Dentz
