From: Scott Murray <scott@spiteful.org>
Subject: Re: [PATCH] SMSC LAN911x and LAN921x vendor driver
Date: Tue, 1 Aug 2006 19:51:32 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0608011710341.23546@godzilla.spiteful.org>
References: <OF2A30C4C9.E3890FDD-ON802571BD.0067817F-802571BD.006AEB8D@smsc.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Bahadir Balban <Bahadir.Balban@arm.com>, ian.saturley@smsc.com,
	netdev@vger.kernel.org, Francois Romieu <romieu@fr.zoreil.com>,
	Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tomts10.bellnexxia.net ([209.226.175.54]:24995 "EHLO
	tomts10-srv.bellnexxia.net") by vger.kernel.org with ESMTP
	id S1750750AbWHAXve (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 19:51:34 -0400
To: Steve.Glendinning@smsc.com
In-Reply-To: <OF2A30C4C9.E3890FDD-ON802571BD.0067817F-802571BD.006AEB8D@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 1 Aug 2006, Steve.Glendinning@smsc.com wrote:

> Hi Scott
>
>> Sorry to be coming in late, but I'm curious about why this work is being
>> submitted as a separate driver, rather than as patches against the
> driver
>> from Dustin McIntire that was added a few months ago.  Is the intention
> to
>> go forward with two different drivers for these chips?
>
> I was waiting for someone to ask this!
>
> This driver has been developed by SMSC & ARM, and has several advantages
> over the already merged smc911x:
>
> - The current driver is arm specific, our smsc911x driver is tested and
> supported on arm, sh, i386
> - smsc911x contains support for the new LAN921x family, as well as LAN911x
> - smsc911x contains important workarounds for currently known hardware
> issues
> - It's shorted, and I believe the coding style to be cleaner and easier to
> follow.
>
> so I'm presenting this as an alternative.  Thoughts?

I think the main concern that my co-workers here at SOMA Networks and I 
have is that having two drivers dilutes the community effort.  There's
also the fact that smc911x seems to have DMA support, which smsc911x does 
not.  Unless there are plans to enhance smsc911x with DMA support, it 
would seem to me to make more sense to apply the LAN921x support and 
hardware workaround changes to smc911x.

Scott


-- 
==============================================================================
Scott Murray, scott@spiteful.org

      "Good, bad ... I'm the guy with the gun." - Ash, "Army of Darkness"
