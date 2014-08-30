From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: RTNL: assertion failed at net/ipv6/addrconf.c (1699)
Date: Sat, 30 Aug 2014 19:11:06 +0200
Message-ID: <20140830171106.GA4698@kria>
References: <CA+ydwtoDwQVg_BWrxxdpUyJ7Up60GtxTCLYe_5vFdV2td_kGhQ@mail.gmail.com>
 <CAHA+R7MZCDGRhSf=UuVCGQvNo03wVziZQB_X30rwNf6hmHipQA@mail.gmail.com>
 <20140829195339.GA9780@kria>
 <1409363489.2980.17.camel@localhost>
 <20140830105821.GB18155@kria>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Cong Wang <cwang@twopensource.com>,
	Tommi Rantala <tt.rantala@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, trinity@vger.kernel.org,
	Dave Jones <davej@redhat.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3-g21.free.fr ([212.27.42.3]:30268 "EHLO smtp3-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751689AbaH3RLU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Aug 2014 13:11:20 -0400
Content-Disposition: inline
In-Reply-To: <20140830105821.GB18155@kria>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-08-30, 12:58:21 +0200, Sabrina Dubroca wrote:
>    - pndisc_constructor, called from pneigh_lookup -- pneigh_lookup
>      has ASSERT_RTNL(), but pneigh_lookup is called from ip6_forward and
>      ndisc_recv_na

Ah, these have creat = 0, so it's fine. I missed that earlier.

Sorry for the noise.

-- 
Sabrina
