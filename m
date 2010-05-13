From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] net sched: cleanup and rate limit warning
Date: Thu, 13 May 2010 15:12:52 +0200
Message-ID: <4BEBFAD4.1030608@trash.net>
References: <20100511172412.76aff184@nehalam>	 <1273684674.16074.0.camel@bigi> <20100512111706.616dc7cf@nehalam>	 <1273691628.16074.15.camel@bigi>  <20100512132042.3b38da18@nehalam> <1273696903.16074.25.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55152 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751512Ab0EMNMz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 May 2010 09:12:55 -0400
In-Reply-To: <1273696903.16074.25.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

jamal wrote:
> On Wed, 2010-05-12 at 13:20 -0700, Stephen Hemminger wrote:
> 
>> The tool isn't generating an action (just tc filter ... police ..)
>> so it is getting the unfortunate default of reclassify.
> 
> Ah ok. 
> My advice: you should never ever depend on defaults when you
> can be explicit and say "drop". Or have the users in your tool be able
> to specify what action to take if rate is exceeded etc (actually i think
> juniper does that) 
> I think "drop" would be the sane default for over-limit - my memory is
> hazy because i assumed that was the default but there may have been some
> reservations on that default. Patrick?

I don't remeber ever discussing that, the choice of "reclassify" as
default precedes TC actions and is already present in the oldest
iproute2 version I could find (2.2.4-ss000225).
