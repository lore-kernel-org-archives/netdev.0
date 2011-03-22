From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [GIT] Networking
Date: Tue, 22 Mar 2011 11:00:10 +0100
Message-ID: <20110322100010.GB26130@elte.hu>
References: <20110320.195156.226769634.davem@davemloft.net>
 <AANLkTinN3qszBjbJdkXb2TPBkAW0mXGC=Ri1zKL9gdNg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <AANLkTinN3qszBjbJdkXb2TPBkAW0mXGC=Ri1zKL9gdNg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Sun, Mar 20, 2011 at 7:51 PM, David Miller <davem@davemloft.net> w=
rote:
> >
> > 1) The R8169 PHY fix from Eric Dumazet, which I see you've added to
> > =A0 your tree too. :-)
>=20
> Yeah, since my machine didn't have networking without it, and I could
> test it myself, I didn't wait to pull.
>=20
> That said, I'm delaying this pull request due to the known issues wit=
h
> it - let me know when you've updated it with the fix for the
> use-after-free fixes and the slab corruptor (the latter of which I
> haven't seen a patch for yet)

All problems i was able to trigger in this area are fixed by these patc=
hes:

 ipvs: Fix a typo in __ip_vs_control_init()
 IPVS: Use global mutex in ip_vs_app.c
 ipx: Fix ipx_release()
 net/appletalk: fix atalk_release use after free

Thanks,

	Ingo
