From: Patrick McHardy <kaber@trash.net>
Subject: Re: one more... iproute commands lockup whole system
Date: Wed, 04 Apr 2007 03:39:12 +0200
Message-ID: <461301C0.2050409@trash.net>
References: <20070321175951.M73913@visp.net.lb> <46026717.9060909@trash.net>	 <20070322124533.M79867@visp.net.lb> <46027FF2.6020001@trash.net>	 <20070322101224.3e6bb899@freekitty>  <20070404000054.M58020@visp.net.lb> <1175649016.3957.10.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Denys <denys@visp.net.lb>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:46627 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966257AbXDDBjP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2007 21:39:15 -0400
In-Reply-To: <1175649016.3957.10.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Wed, 2007-04-04 at 03:03 +0300, Denys wrote:
> 
>>I'm not sure it is mistake or error, but i feel it is dangerous, cause 
>>commands locking up the system, no kernel panic, no oops, so only watchdog 
>>can save poor server (and not sure this even)
>>
>>Commands to lockup system (just i am giving my example, i didnt sort out what 
>>exactly locked up system, i guess redirecting to eth0.5, which is not 
>>intended for that):
> 
> 
> read:
> doc/actions/mirred-usage


Are you refering to "What NOT to do if you dont want your machine to
crash:"? I think we should make sure users can't even accidentally
crash their box, so this should at least be caught at runtime.
I thought the TTL stuff was intended to avoid this ..

