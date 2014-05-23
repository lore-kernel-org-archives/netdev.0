From: Jim Baxter <jim_baxter@mentor.com>
Subject: Re: skbuff truesize incorrect.
Date: Fri, 23 May 2014 12:13:23 +0100
Message-ID: <537F2D53.5020408@mentor.com>
References: <537E4AFD.20304@mentor.com>	<1400792295.5367.174.camel@edumazet-glaptop2.roam.corp.google.com>	<063D6719AE5E284EB5DD2968C1650D6D1724C490@AcuExch.aculab.com> <87r43k4yhe.fsf@nemi.mork.no> <063D6719AE5E284EB5DD2968C1650D6D1724C7A1@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: 'Eric Dumazet' <eric.dumazet@gmail.com>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"kamal@canonical.com" <kamal@canonical.com>,
	"edumazet@google.com" <edumazet@google.com>,
	"mszeredi@suse.cz" <mszeredi@suse.cz>,
	"fw@strlen.de" <fw@strlen.de>
To: David Laight <David.Laight@ACULAB.COM>,
	=?UTF-8?B?J0Jqw7hybiBNb3JrJw==?= <bjorn@mork.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1724C7A1@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 23/05/14 11:45, David Laight wrote:
> From: Bj=C3=B8rn Mork [mailto:bjorn@mork.no]
>> David Laight <David.Laight@ACULAB.COM> writes:
> ...
>>> Note that some of the usb ethernet drivers allocate large skb then
>>> lie about the truesize.
>>
>> Hmm, which drivers are these?
>=20
> $ grep truesize linux/drivers/net/usb/*
>=20
> asix_88179_178a, smsc95xx, sr9700.
>=20
> 	David
>=20


What are the side effects of changing the truesize, if the original
uncloned skb has the full truesize then isn't the potential memory usag=
e
still counted for the avoidance of OOM?

I suppose if the uncloned skb is deleted you would then have a problem
so a chain of URB's would be the safest solution.

Jim
