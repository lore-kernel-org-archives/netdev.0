From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [Patch net-next 1/2] net: fix a compile error when CONFIG_NET_LL_RX_POLL
 is not set
Date: Thu, 01 Aug 2013 09:54:02 +0300
Message-ID: <51FA060A.2060202@linux.intel.com>
References: <1375326625-21427-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:18437 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751460Ab3HAGyG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Aug 2013 02:54:06 -0400
In-Reply-To: <1375326625-21427-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/08/2013 06:10, Cong Wang wrote:
> From: Cong Wang <amwang@redhat.com>
>=20
> When CONFIG_NET_LL_RX_POLL is not set, I got:
>=20
> net/socket.c: In function =E2=80=98sock_poll=E2=80=99:
> net/socket.c:1165:4: error: implicit declaration of function =E2=80=98=
sk_busy_loop=E2=80=99 [-Werror=3Dimplicit-function-declaration]
>=20
> Fix this by adding a nop when !CONFIG_NET_LL_RX_POLL.
>=20

Good catch!

There is a placeholder function, but it has a typo in the name.
With all the renaming I made a mistake and called the do-nothing
function sk_busy_poll while the implemented function is called sk_busy_=
loop.

so what we need is to rename sk_busy_loop() into sk_busy_poll.

(sorry I'm out of the office so I can't do much more than look at the
code at the moment.)

Thanks,
Eliezer
