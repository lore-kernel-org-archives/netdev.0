From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH 1/2] kaweth: Fix locking to be SMP-safe
Date: Tue, 31 Mar 2009 09:39:08 +0200
Message-ID: <200903310939.09690.oliver@neukum.org>
References: <49d00512.XAF19LdpY1dlK6+U%Larry.Finger@lwfinger.net> <200903300828.45337.oliver@neukum.org> <49D0EC24.4080206@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jgarzik@pobox.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out002.kontent.com ([81.88.40.216]:60579 "EHLO
	smtp-out002.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751268AbZCaHev convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2009 03:34:51 -0400
In-Reply-To: <49D0EC24.4080206@lwfinger.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Montag 30 M=E4rz 2009 17:58:28 schrieb Larry Finger:
> Oliver Neukum wrote:

> > Thanks for this report and the patch. I think, however that it intr=
oduces
> > unneeded locking. It seems to me that we should be fine if we fix
> > kaweth_start_xmit(). That code assumes that it is called with inter=
rupts
> > off and under a spinlock. Is that incorrect?
>
> You are correct in that only the locking in kaweth_start_xmit() needs=
 to be
> changed to lock out the other CPU's. In my testing under extreme cond=
itions

Very good.

> (X server over the network), the interface stalled with no logged mes=
sages.

Do you get something with sysrq-t ?

	Regards
		Oliver

