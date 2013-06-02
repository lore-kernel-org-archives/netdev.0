From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: v3.8.5: "TCP: snd_cwnd is nul, please report this bug."
Date: Sun, 02 Jun 2013 21:21:59 +0200
Message-ID: <874ndg71yg.fsf@nemi.mork.no>
References: <87zjx9pf13.fsf@nemi.mork.no>
	<1365431422.3887.10.camel@edumazet-glaptop>
	<87li8tyrzs.fsf@nemi.mork.no>
	<1365434301.3887.14.camel@edumazet-glaptop>
	<87k3mcizlm.fsf@nemi.mork.no>
	<1370182956.24311.34.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:60008 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755748Ab3FBTWG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Jun 2013 15:22:06 -0400
In-Reply-To: <1370182956.24311.34.camel@edumazet-glaptop> (Eric Dumazet's
	message of "Sun, 02 Jun 2013 07:22:36 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:
> On Sun, 2013-06-02 at 12:19 +0200, Bj=C3=B8rn Mork wrote:
>
>> Just FYI, in case you wondered what happened here...
>>=20
>> I've been running with the debug patch since you sent it to me, and
>> still is.  But the warning has not yet reappeared.
>>=20
>> I'll continue using the patch for a while, but will eventually drop =
it
>> if the warning cannot be reproduced in another couple of weeks time.
>> There have been a few fixes to iwlwifi in the meantime, and I do not
>> rule out the possibility that some of these removed the triggering
>> event.
>>=20
>
> What exact tree are you running ?

I am currently testing the mainline v3.10-rcX releases.  I.e. v3.10-rc4
right now.

> F-RTO code was replaced by Yuching Cheng, and it might very well have
> solved these issues.
>
> commit e33099f96d99c391b3325caa9c44258de04aae86=20
> ("tcp: implement RFC5682 F-RTO")
>
> commit ab42d9ee3d215ab74a49818ffc53771a88ce7ddf
> ("tcp: refactor CA_Loss state processing")
>
> commit 9b44190dc114c1720b34975b5bfc65aece112ced
> ("tcp: refactor F-RTO")

Right.

I'll assume the problem is fixed then.  Will drop the debug patch for
now, but resurrect it and let you know if I ever see the warning again.


Bj=C3=B8rn
