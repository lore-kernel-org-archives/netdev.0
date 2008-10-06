From: Patrick McHardy <kaber@trash.net>
Subject: Re: Could you make vconfig less stupid?
Date: Tue, 07 Oct 2008 00:26:30 +0200
Message-ID: <48EA9096.8010505@trash.net>
References: <20081006202401.14f03be2@speedy>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55946 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751552AbYJFW0j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2008 18:26:39 -0400
In-Reply-To: <20081006202401.14f03be2@speedy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> vconfig prints bogus message, then autoloads the vlan module.
> It is still living in 2.4 time warp.
> 
> # vconfig add dummy0 1
> WARNING:  Could not open /proc/net/vlan/config.  Maybe you need to load the 8021q module, or maybe you are not using PROCFS??
> Added VLAN with VID == 1 to IF -:dummy0:-
> 
> Other nuisance:
> # vconfig --version
> Expecting argc to be 3-5, inclusive.  Was: 2
> ...
> 
> 1) users expect version
> 2) users don't expect argc related crap messages

Actually I don't maintain vconfig and I don't think Ben does either.
Its deprecated and iproute is what people should use, all the new
features are not supported by vconfig.

