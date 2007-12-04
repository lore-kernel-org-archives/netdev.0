From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: namespace support requires network modules to say "GPL"
Date: Tue, 04 Dec 2007 13:09:24 -0700
Message-ID: <m1bq96w7bf.fsf@ebiederm.dsl.xmission.com>
References: <m163zi9425.fsf@ebiederm.dsl.xmission.com>
	<47515D39.9030900@rtr.ca> <20071201111736.297dd99a@freepuppy.rosehill>
	<20071201163035.321fd554@freepuppy.rosehill> <475227B1.2060802@rtr.ca>
	<20071201202354.672aed18@freepuppy.rosehill>
	<47530778.7030605@candelatech.com> <47530FAC.1070804@trash.net>
	<m1fxyj1y1y.fsf@ebiederm.dsl.xmission.com>
	<47544896.7070101@candelatech.com> <475451B1.1030006@free.fr>
	<m163zexrqi.fsf@ebiederm.dsl.xmission.com>
	<4755A025.8090903@candelatech.com>
	<m1odd6w9p6.fsf@ebiederm.dsl.xmission.com>
	<4755AC13.1060904@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Lezcano <daniel.lezcano@free.fr>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, containers@lists.osdl.org,
	Mark Lord <lkml@rtr.ca>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:54932 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754176AbXLDULN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2007 15:11:13 -0500
In-Reply-To: <4755AC13.1060904@candelatech.com> (Ben Greear's message of "Tue,
	04 Dec 2007 11:35:47 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear <greearb@candelatech.com> writes:

> Ok, but can a netdev at least know what namespace it is in?  I don't
> need this for my module, but it seems very useful knowledge...

Sure.   dev->nd_net
It is a don't care not a don't know, and there should be device
events when it goes in and out of a network namespace.

I don't know if the device gets those or not.

Eric
