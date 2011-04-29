From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [Linux-ATM-General] [PATCH v2 1/1] solos-pci: Fix regression
 introduced by newest firmware
Date: Sat, 30 Apr 2011 00:09:48 +0100
Message-ID: <1304118588.32168.71.camel@macbook.infradead.org>
References: <1300676496.26693.318.camel@localhost>
	 <20110320.215704.193716335.davem@davemloft.net>
	 <4D86E89B.1060905@redfish-solutions.com>
	 <20110320.230408.112594622.davem@davemloft.net>
	 <4D86FD63.1090405@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, bhutchings@solarflare.com,
	netdev@vger.kernel.org, linux-atm-general@lists.sourceforge.net
To: Philip Prindeville <philipp_subx@redfish-solutions.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:41951 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758091Ab1D2XJ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2011 19:09:56 -0400
In-Reply-To: <4D86FD63.1090405@redfish-solutions.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-03-21 at 00:25 -0700, Philip Prindeville wrote:
> On 3/20/11 11:04 PM, David Miller wrote:
> > From: Philip Prindeville<philipp_subx@redfish-solutions.com>
> > Date: Sun, 20 Mar 2011 22:56:43 -0700
> >
> >> It's not clear that dropping all VCs abruptly when carrier flapped was
> >> ever the right thing to do.
> > So you've tested your change with the older firmware present?
> 
> I haven't, no: back-revving firmware has been known to brick cards.
> 
> I'm waiting to hear back from Guy and Nathan, they have old cards on hand that they can test.

I have JTAG on one of mine and can test, but there's no real need in
this case. If you want to simulate the absence of the 'state changed'
notification, just *ignore* it when it does arrive.

-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation

