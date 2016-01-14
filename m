From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: net/sctp: use-after-free in __sctp_connect
Date: Wed, 13 Jan 2016 23:45:45 -0200
Message-ID: <5696FDC9.6030508@gmail.com>
References: <CACT4Y+YjpSKvD5t8e6wKzE8+j3rFzf_Ep+23WjW1Mg3ws6cOCw@mail.gmail.com>
 <07B7943445653648AD9B4DBB916BB48F04FDFD85@cnshjmbx01>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: YUAN Jia <Jia.Yuan@alcatel-sbell.com.cn>,
	'Dmitry Vyukov' <dvyukov@google.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <07B7943445653648AD9B4DBB916BB48F04FDFD85@cnshjmbx01>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em 13-01-2016 23:37, YUAN Jia escreveu:
 > Hi Dmitry,
 >
 > I've tested your program, but found nothing happens. So, I suspect i=
t=20
may cause kernel crash only on some special kernel version?
 > I was just using kernel of 4.2.3. What about you?
 >
 > Richard

Please don't top-post.

Note that it doesn't necessarily crashes the system. syzkaller is using=
=20
kasan to detect such type of invalid accesses, which in some conditions=
=20
may lead to crashes, weird behavior or just nothing at all. It all=20
depends on how much the memory was already changed after it was freed.

 > -----Original Message-----
 > From: linux-sctp-owner@vger.kernel.org=20
[mailto:linux-sctp-owner@vger.kernel.org] On Behalf Of Dmitry Vyukov
 > Sent: 2016=E5=B9=B41=E6=9C=8813=E6=97=A5 17:53
 > To: Vlad Yasevich; Neil Horman; David S. Miller;=20
linux-sctp@vger.kernel.org; netdev; LKML; Eric Dumazet; Marcelo Ricardo=
=20
Leitner
 > Cc: syzkaller; Kostya Serebryany; Alexander Potapenko; Sasha Levin
 > Subject: net/sctp: use-after-free in __sctp_connect
 >

=2E..

 >
 > On commit 03891f9c853d5c4473224478a1e03ea00d70ff8d (Jan 11).

This is the git commit/(version) he was using --^

Marcelo
