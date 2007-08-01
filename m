From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: Re: [PATCH] SMSC LAN911x and LAN921x vendor driver
Date: Thu, 02 Aug 2007 00:27:40 +0200
Message-ID: <87hcnioppf.fsf@p4.be.48ers.dk>
References: <OF5F9C7C7D.04B8DBCD-ON80257328.0063528D-80257328.0065CB53@smsc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bahadir Balban <Bahadir.Balban@arm.com>,
	Bill Gatliff <bgat@billgatliff.com>,
	Dustin Mcintire <dustin@sensoria.com>, ian.saturley@smsc.com,
	netdev@vger.kernel.org
To: Steve.Glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp40.mobistarmail.be ([193.252.23.61]:26475 "EHLO
	smtp40.mobistarmail.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753776AbXHAW0o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Aug 2007 18:26:44 -0400
Received: from me-wanadoo.net (localhost [127.0.0.1])
	by mwinf4017.mobistarmail.be (SMTP Server) with ESMTP id B4F8870000A5
	for <netdev@vger.kernel.org>; Thu,  2 Aug 2007 00:26:42 +0200 (CEST)
In-Reply-To: <OF5F9C7C7D.04B8DBCD-ON80257328.0063528D-80257328.0065CB53@smsc.com>
	(Steve Glendinning's message of "Mon, 30 Jul 2007 19:31:51 +0100")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>>>> "Steve" == Steve Glendinning <Steve.Glendinning@smsc.com> writes:

Hi,

 >> What's the problem with Dustin's driver? It seems to work fine here
 >> with a lan9117. Why not just add lan921x support to the existing
 >> driver?

 Steve> I have heard Dustin's driver works very well on PXA, but on
 Steve> others it doesn't even compile (hence why it depends on
 Steve> ARCH_PXA).

I'm using it on PPC.

 Steve> Dustin's driver was based on the smc91x code, but these two
 Steve> ethernet devices share nothing other than a similar name.
 Steve> smsc911x is a new, completely platform-independent driver with
 Steve> workarounds for several hardware issues, and it doesn't suffer
 Steve> from quite as much macro abuse :-)

The macros are not that bad as the hw people sligtly misconnected the
chip, so I need special access routines (enable the big endian mode,
not byteswap on normal registar access and byteswap on fifo access).

I'll give your driver a try and report back.

-- 
Bye, Peter Korsgaard

