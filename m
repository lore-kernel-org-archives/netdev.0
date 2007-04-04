From: Patrick McHardy <kaber@trash.net>
Subject: Re: one more... iproute commands lockup whole system
Date: Wed, 04 Apr 2007 16:39:12 +0200
Message-ID: <4613B890.4000005@trash.net>
References: <20070321175951.M73913@visp.net.lb> <46026717.9060909@trash.net>	 <20070322124533.M79867@visp.net.lb> <46027FF2.6020001@trash.net>	 <20070322101224.3e6bb899@freekitty>  <20070404000054.M58020@visp.net.lb>	 <1175649016.3957.10.camel@localhost> <461301C0.2050409@trash.net>	 <20070404020622.M69215@visp.net.lb> <1175684114.4088.12.camel@localhost>	 <4613A9F6.8000307@trash.net> <1175695102.4063.4.camel@localhost>	 <4613B13C.3010603@trash.net> <1175697054.4063.13.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Denys <denys@visp.net.lb>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60494 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753901AbXDDOjP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2007 10:39:15 -0400
In-Reply-To: <1175697054.4063.13.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Wed, 2007-04-04 at 16:07 +0200, Patrick McHardy wrote:
> 
>>How about adding something like ifb's ri_tasklet to act_mirred?
> 
> 
> You mean having a tasklet or the constraint checks?


Have a tasklet to avoid the deadlocks.
