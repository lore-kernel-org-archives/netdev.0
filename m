From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 1/7] [NET]: uninline skb_put, de-bloats a lot
Date: Thu, 27 Mar 2008 12:10:50 -0700
Message-ID: <1206645050.4849.77.camel@localhost>
References: <1206621486-5408-1-git-send-email-ilpo.jarvinen@helsinki.fi>
	 <1206621486-5408-2-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	Matt Mackall <mpm@selenic.com>
To: Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.labridge.com ([206.117.136.22]:4783 "EHLO
	mail.perches.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1755400AbYC0TL3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 15:11:29 -0400
In-Reply-To: <1206621486-5408-2-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-03-27 at 14:38 +0200, Ilpo J=C3=A4rvinen wrote:
> Allyesconfig (v2.6.24-mm1):

I think this change is only good in severely memory
limited uses.  This will very likely negatively impact
high speed networking.  It's a speed/size trade off.

Perhaps a CONFIG option to reduce net code size would
be appropriate.

