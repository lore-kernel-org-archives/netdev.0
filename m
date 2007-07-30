From: Steve.Glendinning@smsc.com
Subject: Re: [PATCH] SMSC LAN911x and LAN921x vendor driver
Date: Mon, 30 Jul 2007 19:31:51 +0100
Message-ID: <OF5F9C7C7D.04B8DBCD-ON80257328.0063528D-80257328.0065CB53@smsc.com>
References: <874pjn3paf.fsf@p4.be.48ers.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Bahadir Balban <Bahadir.Balban@arm.com>,
	Bill Gatliff <bgat@billgatliff.com>,
	Dustin Mcintire <dustin@sensoria.com>, ian.saturley@smsc.com,
	netdev@vger.kernel.org
To: Peter Korsgaard <jacmet@sunsite.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smsc.com ([170.129.50.11]:2322 "EHLO smsc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S967543AbXG3Sc0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Jul 2007 14:32:26 -0400
In-Reply-To: <874pjn3paf.fsf@p4.be.48ers.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Peter,

> What's the problem with Dustin's driver? It seems to work fine here
> with a lan9117. Why not just add lan921x support to the existing
> driver?

I have heard Dustin's driver works very well on PXA, but on others it 
doesn't even compile (hence why it depends on ARCH_PXA).

Dustin's driver was based on the smc91x code, but these two ethernet 
devices share nothing other than a similar name.  smsc911x is a new, 
completely platform-independent driver with workarounds for several 
hardware issues, and it doesn't suffer from quite as much macro abuse :-)

Regards,
--
Steve Glendinning
SMSC GmbH
m: +44 777 933 9124
e: steve.glendinning@smsc.com

