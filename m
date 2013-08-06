From: Teco Boot <teco@inf-net.nl>
Subject: Re: Linux IPV6_SUBTREES not functioning
Date: Tue, 6 Aug 2013 10:46:43 +0200
Message-ID: <013B2D02-AE77-4213-A929-3E35F9C9BF0F@inf-net.nl>
References: <8CBF8819-E1D9-445E-9E7C-793422934733@inf-net.nl> <20130806083005.GC2941@order.stressinduktion.org>
Mime-Version: 1.0 (Mac OS X Mail 6.5 \(1508\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, boutier@pps.univ-paris-diderot.fr
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f176.google.com ([209.85.215.176]:52072 "EHLO
	mail-ea0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754687Ab3HFIqs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Aug 2013 04:46:48 -0400
Received: by mail-ea0-f176.google.com with SMTP id q16so64342ead.35
        for <netdev@vger.kernel.org>; Tue, 06 Aug 2013 01:46:46 -0700 (PDT)
In-Reply-To: <20130806083005.GC2941@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Hannes,

Yes problems with real traffic, with CORE (open source mobile ad hoc network emulator currently maintained by NRL and Boeing).
Mattieu had same problems and therefore stepped to the ip rule. Most, if not all, take this ip rule hack. But then, for each and every source prefix a complete routing table is needed. This is a bad thing and shall be avoided.

Do you think it should work? Have it working? If so, I want to reproduce.

Thanks, Teco

Op 6 aug. 2013, om 10:30 heeft Hannes Frederic Sowa <hannes@stressinduktion.org> het volgende geschreven:

> Hi!
> 
> On Fri, Aug 02, 2013 at 12:15:03PM +0200, Teco Boot wrote:
>> For destination & source address routing, I prefer the single routing table approach with IPV6_SUBTREES over the multiple tables with ip rules approach.
>> Can some take a look at my findings? It looks broken. It seems the source address check in route cache is missing.
> 
> Have you verified this behaviour with actual network traffic?
> 
> Greetings,
> 
>  Hannes
> 
