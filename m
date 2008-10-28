From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: tg3:No interrupt was generated using MSI, switching to INTx
 mode. Please report this failure to the PCI maintainer and include
 system chipset information.
Date: Tue, 28 Oct 2008 13:29:20 -0700
Message-ID: <1225225760.9170.59.camel@HP1>
References: <1225191510.26840.6.camel@localhost>
 <20081028.120419.252131562.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "donner@dbd-breitband.de" <donner@dbd-breitband.de>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3377 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752678AbYJ1Ubp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Oct 2008 16:31:45 -0400
In-Reply-To: <20081028.120419.252131562.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 2008-10-28 at 12:04 -0700, David Miller wrote:
> From: Marc Donner <donner@dbd-breitband.de>
> Date: Tue, 28 Oct 2008 11:58:30 +0100
> 
> Please report networking problems to netdev@vger.kernel.org
> (added to CC:)
> 
> Many networking developers do not read linux-kernel
> 
> > Hi @all,
> > 
> > we have installed a dual port Brodcam Gigabit Ethernet NIC, and get the
> > following error in dmesg:
> > 
> > tg3: eth1 No interrupt was generated using MSI, switching to INTx mode.
> > Please report this failure to the PCI maintainer and include system
> > chipset information.
> > 
> > Who is responsible for this error message? We are using Kernel 2.6.21.1
> > and the NIC Chipset is a Broadcom BCM5715CKPBG
> > 

This message means that your system chipset (not the NIC) does not
support MSI.  Please provide lspci -vvv to show the system chipset on
your system.  Thanks.


