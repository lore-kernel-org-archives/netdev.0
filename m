From: David Miller <davem@davemloft.net>
Subject: Re: [NET_SCHED]: policer: restore compatibility with old iproute
 binaries
Date: Thu, 30 Nov 2006 19:54:29 -0800 (PST)
Message-ID: <20061130.195429.85820511.davem@davemloft.net>
References: <45699DD7.8080408@trash.net>
	<4466a10611300343s2e5fe865t874a9f74bb75fe81@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:17634
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1758851AbWLADy0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Nov 2006 22:54:26 -0500
To: hadi@cyberus.ca
In-Reply-To: <4466a10611300343s2e5fe865t874a9f74bb75fe81@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Thu, 30 Nov 2006 06:43:36 -0500

> On 11/26/06, Patrick McHardy <kaber@trash.net> wrote:
> >
> >
> >
> > [NET_SCHED]: policer: restore compatibility with old iproute binaries
> >
> > The tc actions increased the size of struct tc_police, which broke
> > compatibility with old iproute binaries since both the act_police
> > and the old NET_CLS_POLICE code check for an exact size match.
> >
> > Since the new members are not even used, the simple fix is to also
> > accept the size of the old structure. Dumping is not affected since
> > old userspace will receive a bigger structure, which is handled fine.
> >
> > Signed-off-by: Patrick McHardy <kaber@trash.net>
> 
> 
> Sorry, couldnt respond sooner. Was travelling and overloaded.
> Looks good although i havent run any of my tests. I will at some point.
> 
> Acked-by: Jamal Hadi  Salim

Applied to net-2.6.20, and I'll push this to -stable too.

Thanks everyone.
