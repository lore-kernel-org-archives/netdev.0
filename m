From: "Perla, Sathya" <Sathya.Perla@Emulex.Com>
Subject: RE: [PATCH 1/2] benet: Wait f/w POST until timeout
Date: Wed, 6 Mar 2013 04:45:03 +0000
Message-ID: <dd3bebd7-d92d-4485-b4a6-413df763b985@CMEXHTCAS1.ad.emulex.com>
References: <1362383327-32362-1-git-send-email-shangw@linux.vnet.ibm.com>
 <20130305.163431.2055740152739079020.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Seetharaman, Subramanian" <subbu.seetharaman@emulex.com>,
	"Khaparde, Ajit" <Ajit.Khaparde@Emulex.Com>
To: David Miller <davem@davemloft.net>,
	"shangw@linux.vnet.ibm.com" <shangw@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:42667 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752536Ab3CFEpJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Mar 2013 23:45:09 -0500
In-Reply-To: <20130305.163431.2055740152739079020.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> 
> From: Gavin Shan <shangw@linux.vnet.ibm.com>
> Date: Mon,  4 Mar 2013 15:48:46 +0800
> 
> > While PCI card faces EEH errors, reset (usually hot reset) is expected
> > to recover from the EEH errors. After EEH core finishes the reset, the
> > driver callback (be_eeh_reset) is called and wait the firmware to
> > complete POST successfully. The original code would return with error
> > once detecting failure during POST stage. That seems not enough.
> >
> > The patch forces the driver (be_eeh_reset) to wait the firmware
> > completes POST until timeout, instead of returning error upon
> > detection POST failure immediately. Also, it would improve the
> > reliability of the EEH funtionality of the driver.
> >
> > Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
> 
> I know that patch #2 of this series needs to be implemented differently, but this
> patch seems fine.
> 
> So can I get an ACK from one of the benet driver folks?

Acked-by: Sathya Perla <sathya.perla@emulex.com>

thanks!
