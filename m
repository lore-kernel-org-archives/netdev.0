From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH v2 16/16] skge: convert to hw_features
Date: Mon, 31 Jan 2011 22:53:43 +0100
Message-ID: <20110131215343.GA19379@rere.qmqm.pl>
References: <cover.1295734270.git.mirq-linux@rere.qmqm.pl> <34b51af1d2b880439d2d210837fc87a89c0b9ec4.1295734271.git.mirq-linux@rere.qmqm.pl> <20110131084502.7be146e7@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:41428 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756230Ab1AaVxo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jan 2011 16:53:44 -0500
Content-Disposition: inline
In-Reply-To: <20110131084502.7be146e7@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 31, 2011 at 08:45:02AM -0800, Stephen Hemminger wrote:
> On Sat, 22 Jan 2011 23:14:14 +0100 (CET)
> Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl> wrote:
> > The hardware might do full HW_CSUM, not just IP_CSUM, but it's not =
tested
> > and so not changed here.
> > Signed-off-by: Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>
> The skge hardware does not do full HW_CSUM. It looks at the IP header=
=2E

Driver code suggests otherwise. Please look at skge_xmit_frame() and TX
descriptor format.

Besides, I'm locally using a patch that makes skge advertise HW_CSUM - =
TCP
over IPv6 is correctly checksummed in hardware (haven't tried VLANs yet=
).

Best Regards,
Micha=B3 Miros=B3aw
