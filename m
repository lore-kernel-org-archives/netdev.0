From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next v5 00/10] Support for the Broadcom GENET driver
Date: Tue, 18 Feb 2014 08:37:50 +0100
Message-ID: <20140218073750.GA6316@netboy>
References: <1392336531-28875-1-git-send-email-f.fainelli@gmail.com>
 <52FDC094.1020104@gmail.com>
 <20140214091943.GB3906@netboy>
 <12896228.bQPud9hHaP@lenovo>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, cernekee@gmail.com,
	mark.rutland@arm.com, romieu@fr.zoreil.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:61332 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751239AbaBRHh7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Feb 2014 02:37:59 -0500
Content-Disposition: inline
In-Reply-To: <12896228.bQPud9hHaP@lenovo>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 16, 2014 at 10:34:16AM -0800, Florian Fainelli wrote:
> Le vendredi 14 f=E9vrier 2014, 10:19:43 Richard Cochran a =E9crit :
> > On Thu, Feb 13, 2014 at 11:07:00PM -0800, Florian Fainelli wrote:
> > > Le 13/02/2014 21:29, David Miller a =E9crit :
> > > >Series applied, thanks.
> > >=20
> > > Great, thanks David!
> >=20
> > Sorry for the late comment, but how about adding a call to
> > skb_tx_timestamp(), in order to support so_timestamping?
>=20
> The MAC itself is capable of providing a HW timestamp, I will look in=
to this a=20
> little later.

Hardware time stamping is great to have, but it is more work to
implement. In the mean time, adding transmit software time stamping is
just adding a one-liner.

Thanks,
Richard
