From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH] udp: Introduce special NULL pointers for hlist termination
Date: Fri, 31 Oct 2008 17:55:50 +0300
Message-ID: <490B1C76.6090008@openvz.org>
References: <4908627C.6030001@acm.org>	<490874F2.2060306@cosmosbay.com> <49088288.6050805@acm.org>	<49088AD1.7040805@cosmosbay.com> <20081029163739.GB6732@linux.vnet.ibm.com>	<49089BE5.3090705@acm.org> <4908A134.4040705@cosmosbay.com>	<4908AB3F.1060003@acm.org> <20081029185200.GE6732@linux.vnet.ibm.com>	<4908C0CD.5050406@cosmosbay.com> <20081029201759.GF6732@linux.vnet.ibm.com>	<4908DEDE.5030706@cosmosbay.com> <4909D551.9080309@cosmosbay.com> <20081030085126.0d9b956b@extreme> <4909E0A4.7060009@acm.org> <490B183E.3010707@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Corey Minyard <minyard@acm.org>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	paulmck@linux.vnet.ibm.com, benny+usenet@amorsen.dk,
	netdev@vger.kernel.org,
	Christoph Lameter <cl@linux-foundation.org>,
	a.p.zijlstra@chello.nl, johnpol@2ka.mipt.ru,
	Christian Bell <christian@myri.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:42964 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751267AbYJaO5p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Oct 2008 10:57:45 -0400
In-Reply-To: <490B183E.3010707@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Well, looking at current implementation, I found that udp_v4_mcast_next()
> doesnt take into account the 'struct net *net', so we have a bug here...
> 
> udp_v6_mcast_next() is buggy too (or at least its caller is)
> 
> David, please find a patch against net-2.6
> 
> Thanks
> 
> [PATCH] udp: multicast packets need to check namespace
> 
> Current UDP multicast delivery is not namespace aware.
> 
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Acked-by: Pavel Emelyanov <xemul@openvz.org>

Thanks!

> ---
>  net/ipv4/udp.c |   14 ++++++++------
>  net/ipv6/udp.c |    8 ++++----
>  2 files changed, 12 insertions(+), 10 deletions(-)
> 

