From: Scott Murray <scott@spiteful.org>
Subject: Re: [PATCH] SMSC LAN911x and LAN921x vendor driver
Date: Thu, 3 Aug 2006 17:07:56 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0608031654080.13266@godzilla.spiteful.org>
References: <OF4718982E.55599219-ON802571BF.0054A92B-802571BF.0054D4BB@smsc.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Scott Murray <scott@spiteful.org>,
	Bahadir Balban <Bahadir.Balban@arm.com>, ian.saturley@smsc.com,
	netdev@vger.kernel.org, Francois Romieu <romieu@fr.zoreil.com>,
	Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tomts5.bellnexxia.net ([209.226.175.25]:50312 "EHLO
	tomts5-srv.bellnexxia.net") by vger.kernel.org with ESMTP
	id S932099AbWHCVH6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 17:07:58 -0400
To: Steve.Glendinning@smsc.com
In-Reply-To: <OF4718982E.55599219-ON802571BF.0054A92B-802571BF.0054D4BB@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 3 Aug 2006, Steve.Glendinning@smsc.com wrote:

> Hi Scott,
>
>> I think the main concern that my co-workers here at SOMA Networks
>> and I have is that having two drivers dilutes the community effort.
>> There's also the fact that smc911x seems to have DMA support, which
>> smsc911x does not.  Unless there are plans to enhance smsc911x with
>> DMA support, it would seem to me to make more sense to apply the
>> LAN921x support and hardware workaround changes to smc911x.
>
> I have kept this driver simple for now, focussing on stable support for
> multiple platforms.  While arm is certainly popular, we also have a large
> number of customers on sh, x86 and others, and currently there is no
> in-kernel support (DMA or not) for these people.
>
> Many of our customers use our proprietary drivers (which support DMA on
> many platforms), and we would like to migrate them over to a standard
> in-kernel driver - it would make support easier and everyone can benefit
> from ongoing driver improvements.  The DMA code within these proprietary
> drivers is the next target for submission, although I would like to defer
> additional complexity until we are all happy with the current PIO-only
> implementation.

Okay, I guess I'll shut up.  We're going to stick with smc911x for now 
and will probably submit some patches to it in the near future.  If 
smsc911x gets accepted into mainline by Jeff and gains DMA support, we 
may reconsider.

Scott


-- 
==============================================================================
Scott Murray, scott@spiteful.org

      "Good, bad ... I'm the guy with the gun." - Ash, "Army of Darkness"
