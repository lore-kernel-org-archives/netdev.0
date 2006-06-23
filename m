From: "Ron Mercer" <ron.mercer@qlogic.com>
Subject: RE: New Qlogic qla3xxx NIC Driver v2.02.00k34 for upstream inclusion
Date: Fri, 23 Jun 2006 15:08:35 -0700
Message-ID: <0BB3E5E7462EEA4295BC02D49691DC071769C3@AVEXCH1.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, "Linux Driver" <Linux-Driver@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pat.qlogic.com ([198.70.193.2]:39587 "EHLO avexch1.qlogic.com")
	by vger.kernel.org with ESMTP id S1752113AbWFWWIg convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jun 2006 18:08:36 -0400
Content-class: urn:content-classes:message
To: "Jeff Garzik" <jeff@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 

> Ron Mercer wrote:
> >> 9) [minor] "N/A" appears to be an inaccurate value for 
> fw_version in
> >> ql_get_drvinfo()
> > 
> > Does anyone know what would be appropriate for this ethtool 
> command?  
> > My device does not use firmware.  I took the "N/A" idea 
> from e1000 and 
> > skge.
> 
> It does both ethernet and iSCSI entirely in silicon?
> 
> Is there an easy way to get silicon rev?

There is firmware to support iSCSI.  It is not used by the ethernet
function.

There is no way to get the iSCSI firmware version from the ethernet
function, but there is a way to get silicon rev.


