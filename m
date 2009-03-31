From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH 1/2] kaweth: Fix locking to be SMP-safe
Date: Tue, 31 Mar 2009 17:13:04 +0200
Message-ID: <200903311713.05451.oliver@neukum.org>
References: <49d00512.XAF19LdpY1dlK6+U%Larry.Finger@lwfinger.net> <200903310939.09690.oliver@neukum.org> <49D22EFC.1020709@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jgarzik@pobox.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:49588 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751181AbZCaPJF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2009 11:09:05 -0400
In-Reply-To: <49D22EFC.1020709@lwfinger.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Dienstag 31 M=E4rz 2009 16:55:56 schrieb Larry Finger:
> Oliver Neukum wrote:
> > Very good.
> >
> >> (X server over the network), the interface stalled with no logged
> >> messages.
> >
> > Do you get something with sysrq-t ?
>
> No. The rest of the system was still functioning; however, the driver
> needed to be unloaded and reloaded before continuing. There were no l=
og
> entries until the driver was unloaded.

This sounds like kaweth_tx_timeout() should have been called.
Did you enable enough logging to see
dev_warn(&net->dev, "%s: Tx timed out. Resetting.\n", net->name);

	Regards
		Oliver

