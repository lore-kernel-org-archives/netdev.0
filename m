From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [RFC][PATCH 1/1] net: support for hardware timestamping
Date: Wed, 30 Jul 2008 11:34:49 +0200
Message-ID: <200807301134.49978.netdev@axxeo.de>
References: <1217290080-4251-1-git-send-email-opurdila@ixiacom.com> <200807291911.10364.opurdila@ixiacom.com> <1217407864.30512.111.camel@ecld0pohly>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Octavian Purdila <opurdila@ixiacom.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
To: Patrick Ohly <patrick.ohly@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:44640 "EHLO mail.axxeo.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757557AbYG3Je7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jul 2008 05:34:59 -0400
In-Reply-To: <1217407864.30512.111.camel@ecld0pohly>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Patrick,

Patrick Ohly schrieb:
> Perhaps the parameter of the new
> SO_TXTIMESTAMP can be a multi-value? 0 = no TX time stamps, 1 = TX time
> stamp in hardware if possible with software as fallback, 2 = only
> hardware TX time stamps. Either that, or use the same new socket flag as
> for RX time stamps.

Perhaps we can make it a bitmask (please choose a good prefix instead of XXX):

enum {
	XXX_SOFTWARE_TX_TIMESTAMP = (1 << 0),
	XXX_SOFTWARE_RX_TIMESTAMP = (1 << 1),
	XXX_DRIVER_TX_TIMESTAMP	  = (1 << 2),
	XXX_DRIVER_RX_TIMESTAMP	  = (1 << 3),
};

That way we can express everything required so far and have some bits left 
to define precision, system time correlation and more.


Best Regards

Ingo Oeser
