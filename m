From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH net] net: usbnet: prevent buggy devices from killing us
Date: Thu, 24 Jan 2013 23:09:26 +0100
Message-ID: <1794053.fjSaMDVud2@linux-5eaq.site>
References: <2556579.vjYlY1iKn5@linux-5eaq.site> <1359055016-13603-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:39392 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754597Ab3AXWJ3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2013 17:09:29 -0500
In-Reply-To: <1359055016-13603-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 24 January 2013 20:16:56 Bj=F8rn Mork wrote:
> A device sending 0 length frames as fast as it can has been
> observed killing the host system due to the resulting memory
> pressure.
>=20
> Temporarily disable RX skb allocation and URB submission when
> the current error ratio is high, preventing us from trying to
> allocate an infinite number of skbs.  Reenable as soon as we
> are finished processing the done queue, allowing the device
> to continue working after short error bursts.
>=20
> Signed-off-by: Bj=F8rn Mork <bjorn@mork.no>
> ---
> So is this starting to look OK?

It seems to me that we at least need to try some error recovery.
How about resetting the device when it is no longer used?

	Regards
		Oliver
