From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH/RFC Resubmission] cdc_ether: Identify MBM devices by
 GUID in MDLM descriptor
Date: Fri, 30 Apr 2010 16:28:02 -0700 (PDT)
Message-ID: <20100430.162802.236246160.davem@davemloft.net>
References: <4BD17F81.4070301@ericsson.com>
	<20100427.170959.256868398.davem@davemloft.net>
	<201004281051.44212.oneukum@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jonas.sjoquist@ericsson.com, netdev@vger.kernel.org
To: oneukum@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53310
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755894Ab0D3X15 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Apr 2010 19:27:57 -0400
In-Reply-To: <201004281051.44212.oneukum@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Oliver Neukum <oneukum@suse.de>
Date: Wed, 28 Apr 2010 10:51:44 +0200

> Am Mittwoch, 28. April 2010 02:09:59 schrieb David Miller:
>> From: Jonas Sjoquist <jonas.sjoquist@ericsson.com>
>> Date: Fri, 23 Apr 2010 13:07:45 +0200
>>=20
>> > From: Jonas Sj=F6quist <jonas.sjoquist@ericsson.com>
>> >=20
>> > This patch removes vid/pid for Ericsson MBM devices from the white=
list set of
>> > devices. The MBM devices are instead identified by GUID.
>> >=20
>> > In order for cdc_ether to handle these devices the GUID in the MDL=
M descriptor
>> > is tested. All MBM devices currently handled by cdc_ether as well =
as future
>> > CDC Ethernet MBM devices can be identified by the GUID.
>> >=20
>> > This is the same solution used in Carl Nordbeck's mbm driver,
>> > http://kerneltrap.org/mailarchive/linux-usb/2008/11/17/4141384/thr=
ead
>> >=20
>> > I post this as RFC to get feedback on however cdc_ether is the cor=
rect place to
>> > do the binding, or if it should be done in a separate driver, e.g.=
 zaurus.
>> >=20
>> > Signed-off-by: Jonas Sj=F6quist <jonas.sjoquist@ericsson.com>
>>=20
>> Can someone knowledgable with the cdc_ether driver review this chang=
e?
>=20
> The patch looks good.

Applied to net-next-2.6, thanks everyone.
