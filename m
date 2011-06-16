From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH] tun: teach the tun/tap driver to support netpoll
Date: Thu, 16 Jun 2011 09:44:39 +0800
Message-ID: <4DF96007.50904@redhat.com>
References: <1308151501-8434-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Rik van Riel <riel@redhat.com>,
	Maxim Krasnyansky <maxk@qualcomm.com>,
	"David S. Miller" <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37164 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752385Ab1FPBpG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jun 2011 21:45:06 -0400
In-Reply-To: <1308151501-8434-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2011=E5=B9=B406=E6=9C=8815=E6=97=A5 23:25, Neil Horman =E5=86=
=99=E9=81=93:
> Commit 8d8fc29d02a33e4bd5f4fa47823c1fd386346093 changed the behavior =
of slave
> devices in regards to netpoll.  Specifically it created a mutually ex=
clusive
> relationship between being a slave and a netpoll-capable device.  Thi=
s creates
> problems for KVM because guests relied on needing netconsole active o=
n a slave
> device to a bridge.  Ideally libvirtd could just attach netconsole to=
 the bridge
> device instead, but thats currently infeasible, because while the bri=
dge device
> supports netpoll, it requires that all slave interface also support i=
t, but the
> tun/tap driver currently does not.  The most direct solution is to te=
ach tun/tap
> to support netpoll, which is implemented by the patch below.
>

Yeah, bridge checks if all the underlying devices support netpoll,
that is why Rik saw the failure.


> I've not tested this yet, but its pretty straightforward.
>
> Signed-off-by: Neil Horman<nhorman@tuxdriver.com>
> Reported-by: Rik van Riel<riel@redhat.com>
> CC: Rik van Riel<riel@redhat.com>
> CC: Maxim Krasnyansky<maxk@qualcomm.com>
> CC: Cong Wang<amwang@redhat.com>
> CC: "David S. Miller"<davem@davemloft.net>

Reviewed-by: WANG Cong <amwang@redhat.com>

Thanks for fixing it!
