From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: Please revert removal of /sys/class/net/*/features
Date: Tue, 10 Apr 2012 21:59:56 +0200
Message-ID: <20120410195956.GA28447@rere.qmqm.pl>
References: <20120410110851.5690739c@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:43169 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753398Ab2DJUGI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Apr 2012 16:06:08 -0400
Content-Disposition: inline
In-Reply-To: <20120410110851.5690739c@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 10, 2012 at 11:08:51AM -0700, Stephen Hemminger wrote:
> This commit needs to be reverted. It removed an available sysfs file,=
 and sysfs
> files are part of the ABI. It caused a bug in our current release of =
Vyatta because
> the shell script was using the sysfs file to see if VLAN was supporte=
d on a device.
>=20
> An API maybe redundant, but you can't just remove it.

There was a discussion about it before the patch was accepted. It was
concluded that due to features flags changes, the /sys/class/net/*/feat=
ures
was never a stable API.

Best Regards,
Micha=B3 Miros=B3aw
