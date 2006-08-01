From: Steve.Glendinning@smsc.com
Subject: Re: [PATCH] SMSC LAN911x and LAN921x vendor driver
Date: Tue, 1 Aug 2006 20:27:54 +0100
Message-ID: <OF2A30C4C9.E3890FDD-ON802571BD.0067817F-802571BD.006AEB8D@smsc.com>
References: <Pine.LNX.4.64.0608011351340.23546@godzilla.spiteful.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Bahadir Balban <Bahadir.Balban@arm.com>, ian.saturley@smsc.com,
	netdev@vger.kernel.org, Francois Romieu <romieu@fr.zoreil.com>,
	Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smsc.com ([170.129.50.11]:31492 "EHLO smsc.com")
	by vger.kernel.org with ESMTP id S1751839AbWHAT2T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2006 15:28:19 -0400
In-Reply-To: <Pine.LNX.4.64.0608011351340.23546@godzilla.spiteful.org>
To: Scott Murray <scott@spiteful.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Scott

> Sorry to be coming in late, but I'm curious about why this work is being
> submitted as a separate driver, rather than as patches against the 
driver
> from Dustin McIntire that was added a few months ago.  Is the intention 
to 
> go forward with two different drivers for these chips?

I was waiting for someone to ask this!

This driver has been developed by SMSC & ARM, and has several advantages 
over the already merged smc911x:

- The current driver is arm specific, our smsc911x driver is tested and 
supported on arm, sh, i386
- smsc911x contains support for the new LAN921x family, as well as LAN911x
- smsc911x contains important workarounds for currently known hardware 
issues
- It's shorted, and I believe the coding style to be cleaner and easier to 
follow.

so I'm presenting this as an alternative.  Thoughts?

Regards,
--
Steve Glendinning
SMSC GmbH
m: +44 777 933 9124
e: steve.glendinning@smsc.com


