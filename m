From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH v2 16/16] skge: convert to hw_features
Date: Tue, 1 Feb 2011 00:08:33 +0100
Message-ID: <20110131230833.GA25076@rere.qmqm.pl>
References: <cover.1295734270.git.mirq-linux@rere.qmqm.pl> <34b51af1d2b880439d2d210837fc87a89c0b9ec4.1295734271.git.mirq-linux@rere.qmqm.pl> <20110131084502.7be146e7@nehalam> <20110131215343.GA19379@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:39406 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754285Ab1AaXIe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jan 2011 18:08:34 -0500
Content-Disposition: inline
In-Reply-To: <20110131215343.GA19379@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 31, 2011 at 10:53:43PM +0100, Micha=B3 Miros=B3aw wrote:
> On Mon, Jan 31, 2011 at 08:45:02AM -0800, Stephen Hemminger wrote:
> > On Sat, 22 Jan 2011 23:14:14 +0100 (CET)
> > Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl> wrote:
> > > The hardware might do full HW_CSUM, not just IP_CSUM, but it's no=
t tested
> > > and so not changed here.
> > > Signed-off-by: Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>
> > The skge hardware does not do full HW_CSUM. It looks at the IP head=
er.
> Driver code suggests otherwise. Please look at skge_xmit_frame() and =
TX
> descriptor format.

Ah, I just noticed you wrote most of the code. :-)

Anyway, I still think you're wrong on this. I'll get back to it if I fi=
nd
the time to create a proper test for other people with similar hardware=
=2E
This might be an academic dispute unless we can get at the docs.

Best Regards,
Micha=B3 Miros=B3aw
