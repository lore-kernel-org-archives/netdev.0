From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH 1/2 V2] kaweth: Fix locking to be SMP-safe
Date: Wed, 1 Apr 2009 01:06:10 +0200
Message-ID: <200904010106.10974.oliver@neukum.org>
References: <49d264dd.YwbXLw18YaD1tQqD%Larry.Finger@lwfinger.net> <200904010013.05494.oliver@neukum.org> <20090331.151028.42671906.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Larry.Finger@lwfinger.net, jgarzik@pobox.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:33099 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761311AbZCaXC7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2009 19:02:59 -0400
In-Reply-To: <20090331.151028.42671906.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Mittwoch 01 April 2009 00:10:28 schrieb David Miller:
> > Here you enable interrupts. Are you sure ndo_start_xmit is never
> > called with interrupts disabled?
>
> It must never be invoked that way, this would break so many
> drivers.
>
> On the other hand, all of these driver paths never execute
> in a real hardware interrupt context, the deepest it gets
> into is software interrupts. =A0So spin_*lock*_bh() might be
> more appropriate.

Thanks. The patch is good. I'll check the other USB network
drivers.

	Regards
		Oliver

