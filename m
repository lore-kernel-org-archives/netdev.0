From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH v3 08/13] QLogic VNIC: sysfs interface implementation for the driver
Date: Sat, 31 May 2008 22:46:05 -0700
Message-ID: <ada7id7685e.fsf@cisco.com>
References: <20080529095126.9943.84692.stgit@localhost.localdomain>
	<20080529095754.9943.27936.stgit@localhost.localdomain>
	<20080529103003.010c4a08@extreme> <20080529174805.GA10903@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Ramachandra K <ramachandra.kuchimanchi@qlogic.com>,
	general@lists.openfabrics.org, netdev@vger.kernel.org,
	poornima.kamath@qlogic.com, amar.mudrankit@qlogic.com
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-3.cisco.com ([171.71.176.72]:16183 "EHLO
	sj-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751450AbYFBRrq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2008 13:47:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > And yes, multiple values per sysfs file are not allowed, sorry, please
 > change this.  If you need to configure your device through an interface
 > like this, consider using configfs instead, that is what it is there
 > for.

Makes sense... I know that the SRP initiator uses the method of multiple
'token=<value>' entries passed into sysfs, but the excuse is that SRP
was merged before configfs.

I'll also have a look at adding configfs support to SRP and deprecating
the current sysfs method...

 - R.
