From: David Miller <davem@davemloft.net>
Subject: Re: [patch] caif: remove unneeded null check in caif_connect()
Date: Mon, 31 May 2010 00:32:00 -0700 (PDT)
Message-ID: <20100531.003200.102574775.davem@davemloft.net>
References: <20100522204342.GV22515@bicker>
	<AANLkTikM6_-YgLcBtcxN_TA1ISHkRk6fCEJVOS7pRZel@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: error27@gmail.com, sjur.brandeland@stericsson.com,
	eric.dumazet@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: sjurbren@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTikM6_-YgLcBtcxN_TA1ISHkRk6fCEJVOS7pRZel@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Sjur Br=E6ndeland <sjurbren@gmail.com>
Date: Mon, 24 May 2010 21:56:01 +0200

> Dan Carpenter <error27@gmail.com> wrote:
>> We already dereferenced uaddr towards the start of the function when=
 we
>> checked that "uaddr->sa_family !=3D AF_CAIF". =A0Both the check here=
 and the
>> earlier check were added in bece7b2398d0: "caif: Rewritten socket
>> implementation". =A0Before that patch, we assumed that we recieved a=
 valid
>> pointer for uaddr, and based on that, I have removed this check.
>>
>> Signed-off-by: Dan Carpenter <error27@gmail.com>
> Thanks Looks good,
> Acked-by: Sjur Braendeland <sjur.brandeland@stericsson.com>

Applied.
