From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH/RFC Resubmission] cdc_ether: Identify MBM devices by GUID in MDLM descriptor
Date: Wed, 28 Apr 2010 10:51:44 +0200
Message-ID: <201004281051.44212.oneukum@suse.de>
References: <4BD17F81.4070301@ericsson.com> <20100427.170959.256868398.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jonas.sjoquist@ericsson.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:49172 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751089Ab0D1Ivs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 04:51:48 -0400
In-Reply-To: <20100427.170959.256868398.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Mittwoch, 28. April 2010 02:09:59 schrieb David Miller:
> From: Jonas Sjoquist <jonas.sjoquist@ericsson.com>
> Date: Fri, 23 Apr 2010 13:07:45 +0200
>=20
> > From: Jonas Sj=F6quist <jonas.sjoquist@ericsson.com>
> >=20
> > This patch removes vid/pid for Ericsson MBM devices from the whitel=
ist set of
> > devices. The MBM devices are instead identified by GUID.
> >=20
> > In order for cdc_ether to handle these devices the GUID in the MDLM=
 descriptor
> > is tested. All MBM devices currently handled by cdc_ether as well a=
s future
> > CDC Ethernet MBM devices can be identified by the GUID.
> >=20
> > This is the same solution used in Carl Nordbeck's mbm driver,
> > http://kerneltrap.org/mailarchive/linux-usb/2008/11/17/4141384/thre=
ad
> >=20
> > I post this as RFC to get feedback on however cdc_ether is the corr=
ect place to
> > do the binding, or if it should be done in a separate driver, e.g. =
zaurus.
> >=20
> > Signed-off-by: Jonas Sj=F6quist <jonas.sjoquist@ericsson.com>
>=20
> Can someone knowledgable with the cdc_ether driver review this change=
?

The patch looks good.

	Regards
		Oliver
