From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH 10/10] net: remove SK_ROUTE_CAPS from meta ematch
Date: Thu, 14 Jul 2011 22:50:05 +0200
Message-ID: <20110714205004.GC16759@rere.qmqm.pl>
References: <cover.1310601401.git.mirq-linux@rere.qmqm.pl>
 <b06d1da00c5f333bb5d8d9f01aa306ff69b99df5.1310601401.git.mirq-linux@rere.qmqm.pl>
 <1310605166.2416.0.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:34949 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754211Ab1GNUuG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jul 2011 16:50:06 -0400
Content-Disposition: inline
In-Reply-To: <1310605166.2416.0.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 13, 2011 at 08:59:26PM -0400, jamal wrote:
> On Thu, 2011-07-14 at 02:10 +0200, Micha=B3 Miros=B3aw wrote:
> > Remove it, as it indirectly exposes netdev features. It's not used =
in
> > iproute2 (2.6.38) - is anything else using its interface?
> Breaks user ABI.

No iproute2 version uses it, its meaning have already changed several
times in kernel history and it prevents improving the netdev features
infrastructure. Note that other IDs are not changed - just this one is
turned into unsupported.

Best Regards,
Micha=B3 Miros=B3aw
