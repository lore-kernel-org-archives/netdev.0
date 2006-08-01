From: Scott Murray <scott@spiteful.org>
Subject: Re: [PATCH] SMSC LAN911x and LAN921x vendor driver
Date: Tue, 1 Aug 2006 14:28:06 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0608011351340.23546@godzilla.spiteful.org>
References: <20060728213841.GA14235@electric-eye.fr.zoreil.com>
 <11544451353553-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org, Ian Saturley <ian.saturley@smsc.com>,
	Bahadir Balban <Bahadir.Balban@arm.com>,
	Stephen Hemminger <shemminger@osdl.org>,
	Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tomts40.bellnexxia.net ([209.226.175.97]:53178 "EHLO
	tomts40-srv.bellnexxia.net") by vger.kernel.org with ESMTP
	id S1751775AbWHAS2I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 14:28:08 -0400
To: Steve Glendinning <steve.glendinning@smsc.com>
In-Reply-To: <11544451353553-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 1 Aug 2006, Steve Glendinning wrote:

>>> Attached is a driver patch for SMSC911x family of ethernet chips,
>>> generated against 2.6.18-rc1 sources. There's a similar driver in the
>>> tree; this one has been tested by SMSC on all flavors of the chip and
>>> claimed to be efficient.
>>
>> Updated after feedback from Stephen Hemminger.
>>
>> Driver updated to also support LAN921x family.  Workarounds added for
>> known hardware issues.
>
> Many improvements following feedback from Stephen Hemminger and
> Francois Romieu:
> - Tasklet removed, NAPI poll used instead
> - Multiple device support
> - style fixes & minor improvements

Sorry to be coming in late, but I'm curious about why this work is being
submitted as a separate driver, rather than as patches against the driver
from Dustin McIntire that was added a few months ago.  Is the intention to 
go forward with two different drivers for these chips?

Scott


-- 
==============================================================================
Scott Murray, scott@spiteful.org

      "Good, bad ... I'm the guy with the gun." - Ash, "Army of Darkness"
