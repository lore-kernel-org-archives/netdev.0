From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH resend] drop_monitor: fix trace_napi_poll_hit()
Date: Mon, 31 Aug 2009 15:33:50 +0200
Message-ID: <4A9BD13E.4040501@gmail.com>
References: <4A9B6963.5090207@cn.fujitsu.com> <4A9B6E57.7090703@gmail.com> <20090831111245.GA2105@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Xiao Guangrong <xiaoguangrong@cn.fujitsu.com>,
	David Miller <davem@davemloft.net>,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752690AbZHaNeE@vger.kernel.org>
In-Reply-To: <20090831111245.GA2105@hmsreliant.think-freely.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Neil Horman a =E9crit :
> I still see a large number of drivers that update dev->last_rx, altho=
ugh its
> not all as I look through the list, so something definately seems ami=
ss.

Some drivers still update dev->last_rx for their own needs, not a core
network concern.

But a cleanup is certainly possible on few other drivers, about a dozen
if I count correctly.

>=20
> If its not going to be consistently updated, why are still carrying t=
hat field
> in dev?  Are we just waiting on someone to do the janitorial work to =
remove it?
> If so, I can, and I'll fix up the drop monitor in the process, to use=
 a private
> timestamp.

We have to keep dev->last_rx for bonding use, so please use a private
timestamp for drop monitor.

Thanks
