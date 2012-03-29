From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH V3 0/6] net/mlx4_en: DCB QoS support
Date: Thu, 29 Mar 2012 14:33:32 +0200
Message-ID: <CAJZOPZKY7myh+x1EEKgHHq9vSdzmY8EAeKxS6MUA=EyKmUecAg@mail.gmail.com>
References: <1332860951-23042-1-git-send-email-amirv@mellanox.com>
	<CAJZOPZLLJdQX4i_WhV8Bo5UHaxndFDwf873n8ZTCPqXq7JrMiw@mail.gmail.com>
	<1332990846.3402.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Roland Dreier <roland@purestorage.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Oren Duer <oren@mellanox.com>,
	Amir Vadai <amirv@dev.mellanox.co.il>,
	John Fastabend <john.r.fastabend@intel.com>,
	Amir Vadai <amirv@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:41029 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752583Ab2C2Mde convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Mar 2012 08:33:34 -0400
Received: by lahj13 with SMTP id j13so2393656lah.19
        for <netdev@vger.kernel.org>; Thu, 29 Mar 2012 05:33:33 -0700 (PDT)
In-Reply-To: <1332990846.3402.5.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 29, 2012 at 5:14 AM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le jeudi 29 mars 2012 =E0 00:21 +0200, Or Gerlitz a =E9crit :
>
>> For the ratelimit Eric D. provided feedback and it was implemented a=
long his suggestion,
>
>
> My suggestion was exactly the following :
>
> /sys/class/net/eth2/qos/0/ratelimit
> ...
> /sys/class/net/eth2/qos/7/ratelimit
>
>> and now John and Ben have other suggestions,
>
> I dont think so.
> Amir provided in V2 something that was not what I suggested.
>
> /sys/class/net/eth2/ratelimit/tc0
> ...
> /sys/class/net/eth2/ratelimit/tc7
>
>
> And this is where John, Ben were complaining.
> [ Obviously I totally agree with them ]

to be precise they were suggesting to go e.g through DCBNL and not sysf=
s,
anyway,Amir works to implement this along their suggestion

Or
