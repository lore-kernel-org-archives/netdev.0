From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH/RFC Resubmission] cdc_ether: Identify MBM devices by
 GUID in MDLM descriptor
Date: Tue, 27 Apr 2010 17:09:59 -0700 (PDT)
Message-ID: <20100427.170959.256868398.davem@davemloft.net>
References: <4BD17F81.4070301@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: oneukum@suse.de, netdev@vger.kernel.org
To: jonas.sjoquist@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48019
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752200Ab0D1AJx convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Apr 2010 20:09:53 -0400
In-Reply-To: <4BD17F81.4070301@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Jonas Sjoquist <jonas.sjoquist@ericsson.com>
Date: Fri, 23 Apr 2010 13:07:45 +0200

> From: Jonas Sj=F6quist <jonas.sjoquist@ericsson.com>
>=20
> This patch removes vid/pid for Ericsson MBM devices from the whitelis=
t set of
> devices. The MBM devices are instead identified by GUID.
>=20
> In order for cdc_ether to handle these devices the GUID in the MDLM d=
escriptor
> is tested. All MBM devices currently handled by cdc_ether as well as =
future
> CDC Ethernet MBM devices can be identified by the GUID.
>=20
> This is the same solution used in Carl Nordbeck's mbm driver,
> http://kerneltrap.org/mailarchive/linux-usb/2008/11/17/4141384/thread
>=20
> I post this as RFC to get feedback on however cdc_ether is the correc=
t place to
> do the binding, or if it should be done in a separate driver, e.g. za=
urus.
>=20
> Signed-off-by: Jonas Sj=F6quist <jonas.sjoquist@ericsson.com>

Can someone knowledgable with the cdc_ether driver review this change?

Thanks.
