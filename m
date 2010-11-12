From: "Hua Zhong" <hzhong@gmail.com>
Subject: RE: [RFC PATCH] network: return errors if we know tcp_connect failed
Date: Fri, 12 Nov 2010 15:14:14 -0800
Message-ID: <017301cb82bf$54540cf0$fcfc26d0$@com>
References: <20101111210341.31350.86916.stgit@paris.rdu.redhat.com> <00c201cb81eb$84e18160$8ea48420$@com> <4CDCEE65.3060105@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'Eric Paris'" <eparis@redhat.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <davem@davemloft.net>,
	<kuznet@ms2.inr.ac.ru>, <pekkas@netcore.fi>, <jmorris@namei.org>,
	<yoshfuji@linux-ipv6.org>
To: "'Patrick McHardy'" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:59534 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932584Ab0KLXOS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Nov 2010 18:14:18 -0500
In-Reply-To: <4CDCEE65.3060105@trash.net>
Content-Language: en-us
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On 11.11.2010 22:58, Hua Zhong wrote:
> >> Yes, I realize this is little different than if the
> >> SYN was dropped in the first network device, but it is different
> >> because we know what happened!  We know that connect() call failed
> >> and that there isn't anything coming back.
> >
> > I would argue that -j DROP should behave exactly as the packet is
> dropped in the network, while -j REJECT should signal the failure to
> the application as soon as possible (which it doesn't seem to do).
> 
> It sends an ICMP error or TCP reset. Interpretation is up to TCP.

Huh? It's the OUTPUT chain we are talking about. There is no ICMP error or
TCP reset.

