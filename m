From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH 1/2] kaweth: Fix locking to be SMP-safe
Date: Mon, 30 Mar 2009 08:28:44 +0200
Message-ID: <200903300828.45337.oliver@neukum.org>
References: <49d00512.XAF19LdpY1dlK6+U%Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jgarzik@pobox.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:55307 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752083AbZC3GYW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2009 02:24:22 -0400
In-Reply-To: <49d00512.XAF19LdpY1dlK6+U%Larry.Finger@lwfinger.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Montag 30 M=E4rz 2009 01:32:34 schrieb Larry Finger:
> On an SMP system, the following message is printed. The patch below g=
ets
> fixes the problem.

Thanks for this report and the patch. I think, however that it introduc=
es
unneeded locking. It seems to me that we should be fine if we fix
kaweth_start_xmit(). That code assumes that it is called with interrupt=
s
off and under a spinlock. Is that incorrect?

	Regards
		Oliver

