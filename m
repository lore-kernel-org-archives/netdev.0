From: Oleksandr Natalenko <oleksandr@natalenko.name>
Subject: Re: [REGRESSION] tcp/ipv4: kernel panic because of (possible) division by zero
Date: Sun, 10 Jan 2016 16:57:40 +0200
Message-ID: <4496498.SgxPQx9et6@spock>
References: <26396443.iDTTxgChSj@spock> <CADVnQy=S62KoQL7thY73Kb=1Qd60drvOHJhE8UwH9qzPFOadEg@mail.gmail.com> <CADVnQykvDhCrCuFR0MCiEvD7DUbf+ZVBOysa1iWSE6-FydzqYQ@mail.gmail.com>
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
In-Reply-To: <CADVnQykvDhCrCuFR0MCiEvD7DUbf+ZVBOysa1iWSE6-FydzqYQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Yes, this is my next step. Then I'll try to move from YeAH.

On =D0=BD=D0=B5=D0=B4=D1=96=D0=BB=D1=8F, 10 =D1=81=D1=96=D1=87=D0=BD=D1=
=8F 2016 =D1=80. 09:54:16 EET Neal Cardwell wrote:
> On Sun, Jan 10, 2016 at 9:48 AM, Neal Cardwell <ncardwell@google.com>=
 wrote:
> > On Sun, Jan 10, 2016 at 5:23 AM, Oleksandr Natalenko
> >=20
> > <oleksandr@natalenko.name> wrote:
> >> With the patch queued for upstream and ECN enabled I get WARN_ON_O=
NCE()
> >> triggered. Here is the stacktrace:
> >>=20
> >> https://gist.github.com/89203e77bfcb051f269a
> >>=20
> >> It seems that tp->prior_cwnd is zero.
> >=20
> > Hmm. Interesting. Can you please confirm that you are using the cub=
ic
> > congestion control module?
>=20
> Would you be able to do an experiment where you reboot, and then
> disable ECN upon startup, and then see if the warning still shows up
> without ECN?
>=20
> thanks,
> neal
