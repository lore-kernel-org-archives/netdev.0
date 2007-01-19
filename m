From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH REPOST	1/2]	NET:	Accurate	packet	scheduling	for	ATM/ADSL
 (kernel)
Date: Fri, 19 Jan 2007 13:19:16 +0100
Message-ID: <45B0B744.7070800@trash.net>
References: <1161041677.6247.1.camel@ras.pc.brisbane.lube>	 <1161090444.5555.13.camel@jzny2>  <45378DE3.8080700@trash.net>	 <1161602527.5502.155.camel@ras.pc.stuart.local>	 <453CB801.4010902@trash.net>	 <1161640444.5502.214.camel@ras.pc.stuart.local> <453E3CFC.80007@trash.net>	 <1161733596.3829.91.camel@ras.pc.brisbane.lube>	 <456ED79E.2070707@trash.net> <1169075223.7560.15.camel@ras>	 <45AEF219.2060304@trash.net> <1169100970.21535.18.camel@ras>	 <45AF5C02.1010005@trash.net> <1169176280.1118.8.camel@ras>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60004 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965094AbXASMTR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jan 2007 07:19:17 -0500
To: Russell Stuart <russell-tcatm@stuart.id.au>
In-Reply-To: <1169176280.1118.8.camel@ras>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Russell Stuart wrote:
> On Thu, 2007-01-18 at 12:37 +0100, Patrick McHardy wrote:
> 
>>>Or are you proposing tc behave differently on different
>>>kernel versions.  (I have no problem with that, but
>>>isn't it officially frowned upon?)
>>
>>Yes. There is no way you can make this work on old kernels,
>>nobody expects that. The important part is that everything
>>continues to work as before and that both old and new iproute
>>binaries work properly on both old and new kernels (new
>>iproute on old kernels without STABs obviously).
> 
> 
> I thought that some degree of compatibility was 
> expected.  At the very least the newest version 
> of "tc" must work on _any_ kernel as least as 
> well as the version it replaces did.
> 
> I also though newer kernels should work older
> version of iproute2, albeit without the features
> added in the newer versions.
> 
> Are you saying this is not so?

No, thats exactly what I'm saying.
