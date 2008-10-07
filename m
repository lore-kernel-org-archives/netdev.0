From: Patrick McHardy <kaber@trash.net>
Subject: Re: Could you make vconfig less stupid?
Date: Tue, 07 Oct 2008 15:57:53 +0200
Message-ID: <48EB6AE1.9080005@trash.net>
References: <20081006202401.14f03be2@speedy> <200810071520.56610.denys@visp.net.lb> <20081007124820.GG4606@ntm.vs.lam.cz> <200810071549.16647.denys@visp.net.lb> <48EB5C63.60501@trash.net> <Pine.LNX.4.62.0810071510230.2675@wlug.westbo.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Denys Fedoryshchenko <denys@visp.net.lb>,
	Milan Kocian <milon@wq.cz>,
	Ben Greear <greearb@candelatech.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
To: Martin Josefsson <gandalf@mjufs.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:46758 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753303AbYJGN6A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 09:58:00 -0400
In-Reply-To: <Pine.LNX.4.62.0810071510230.2675@wlug.westbo.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Martin Josefsson wrote:
> On Tue, 7 Oct 2008, Patrick McHardy wrote:
> 
>>>> # ip l a l eth0 type vlan id 100
> 
>> It would be better to have -d as a default, I was afraid of breaking
>> scripts of people sedding and awking around with the iproute output.
> 
> It would also be good to have a help text describing 'ip l a' as
> 'ip l h' doesn't mention it at all in at least iproute2-ss080725 which 
> seems to be the latest release.
> 
> Until there's an easy accessible help text I'll stick to vconfig :)
> I know the iproute help texts aren't always that easy to read but at 
> least they beat getting:
> 
> # ip l a
> RTNETLINK answers: Operation not supported

Actually it seems something broke probing in the kernel, let me look
into it.
