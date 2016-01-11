From: Oleksandr Natalenko <oleksandr@natalenko.name>
Subject: Re: [REGRESSION] tcp/ipv4: kernel panic because of (possible) division by zero
Date: Tue, 12 Jan 2016 01:26:05 +0200
Message-ID: <2260281.VlLhvGfHoN@spock>
References: <26396443.iDTTxgChSj@spock> <3240923.Qg3kfz0Bvr@spock> <CADVnQynzxB7mFyprZnNzUUBNhtaibA+9LRGufDLjSw6QeZou2g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Yuchung Cheng <ycheng@google.com>, netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	James Morris <jmorris@namei.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"David S. Miller" <davem@davemloft.net>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CADVnQynzxB7mFyprZnNzUUBNhtaibA+9LRGufDLjSw6QeZou2g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Compiled and booted OK, no issues so far, but I'd prefer to give it a s=
everal=20
days test.

Thanks!

On =D0=BF=D0=BE=D0=BD=D0=B5=D0=B4=D1=96=D0=BB=D0=BE=D0=BA, 11 =D1=81=D1=
=96=D1=87=D0=BD=D1=8F 2016 =D1=80. 13:47:08 EET Neal Cardwell wrote:
> Great. Thanks for running that test! Yes, I think that's enough info.
> We sent a proposed upstream patch here:
>=20
>   http://patchwork.ozlabs.org/patch/566072/
>   tcp_yeah: don't set ssthresh below 2
>=20
> Feel free to add your "Tested-By" to the thread if you have a chance
> to test that patch.
