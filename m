From: Steve.Glendinning@smsc.com
Subject: Re: [PATCH] SMSC LAN911x and LAN921x vendor driver
Date: Thu, 3 Aug 2006 16:26:38 +0100
Message-ID: <OF4718982E.55599219-ON802571BF.0054A92B-802571BF.0054D4BB@smsc.com>
References: <Pine.LNX.4.64.0608011710341.23546@godzilla.spiteful.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Bahadir Balban <Bahadir.Balban@arm.com>, ian.saturley@smsc.com,
	netdev@vger.kernel.org, Francois Romieu <romieu@fr.zoreil.com>,
	Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smsc.com ([170.129.50.11]:51730 "EHLO smsc.com")
	by vger.kernel.org with ESMTP id S964788AbWHCP07 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2006 11:26:59 -0400
In-Reply-To: <Pine.LNX.4.64.0608011710341.23546@godzilla.spiteful.org>
To: Scott Murray <scott@spiteful.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Scott,

> I think the main concern that my co-workers here at SOMA Networks
> and I have is that having two drivers dilutes the community effort.
> There's also the fact that smc911x seems to have DMA support, which
> smsc911x does not.  Unless there are plans to enhance smsc911x with
> DMA support, it would seem to me to make more sense to apply the
> LAN921x support and hardware workaround changes to smc911x.

I have kept this driver simple for now, focussing on stable support for 
multiple platforms.  While arm is certainly popular, we also have a large 
number of customers on sh, x86 and others, and currently there is no 
in-kernel support (DMA or not) for these people.

Many of our customers use our proprietary drivers (which support DMA on 
many platforms), and we would like to migrate them over to a standard 
in-kernel driver - it would make support easier and everyone can benefit 
from ongoing driver improvements.  The DMA code within these proprietary 
drivers is the next target for submission, although I would like to defer 
additional complexity until we are all happy with the current PIO-only 
implementation.

Regards,
--
Steve Glendinning
SMSC GmbH
m: +44 777 933 9124
e: steve.glendinning@smsc.com

