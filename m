From: jamal <hadi@cyberus.ca>
Subject: Re: Network activity LED trigger
Date: Fri, 02 Mar 2007 09:11:08 -0500
Message-ID: <1172844668.4864.46.camel@localhost>
References: <200703012241.49165.florian.fainelli@int-evry.fr>
	 <200703021358.52224.florian.fainelli@int-evry.fr>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Richard Purdie <rpurdie@rpsys.net>
To: Florian Fainelli <florian.fainelli@int-evry.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.178]:63219 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992466AbXCBOLL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Mar 2007 09:11:11 -0500
Received: by py-out-1112.google.com with SMTP id a29so435220pyi
        for <netdev@vger.kernel.org>; Fri, 02 Mar 2007 06:11:11 -0800 (PST)
In-Reply-To: <200703021358.52224.florian.fainelli@int-evry.fr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Where are these LEDs typically located? Are you talking about LEDs on a
network card for example? can you light them up in different colors?

cheers,
jamal

On Fri, 2007-02-03 at 13:58 +0100, Florian Fainelli wrote:
> Hi All,
> 
> Some more thoughts. The IDE activity LED trigger is currently triggered when a 
> function is called in the IDE writing/reading routines.
> 
> In a similar way, we could call the trigger function in net/core/dev.c in 
> netif_receive_skb and netif_rx ?
> 
> I was also thinking that some network NIC already have LEDs, so it is not 
> necessary for those models to "overload" the user with lights everywhere.
> 
> R

