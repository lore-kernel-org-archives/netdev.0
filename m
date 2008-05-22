From: Helge Hafting <helge.hafting@aitel.hist.no>
Subject: Re: [PATCH] Re: [PATCH] drivers/net: remove network drivers' last
 few uses of IRQF_SAMPLE_RANDOM
Date: Thu, 22 May 2008 11:28:25 +0200
Message-ID: <48353CB9.5080609@aitel.hist.no>
References: <Pine.LNX.4.62.0805150009060.18303@ikari.dreamhost.com> <20080515142154.0595e475@core> <36D9DB17C6DE9E40B059440DB8D95F52052D71BB@orsmsx418.amr.corp.intel.com> <20080515173939.1ec968be@core> <482C7DA3.1090809@garzik.org> <482C953A.4080205@garzik.org> <87abirytxj.fsf@basil.nowhere.org> <20080516105635.6cb1f505@core> <482D5FC5.2070103@firstfloor.org> <20080516121239.GA9627@gondor.apana.org.au> <482DB568.1040704@firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Chris Peterson <cpeterso@cpeterso.com>,
	tpmdd-devel@lists.sourceforge.net, tpm@selhorst.net
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from embla.aitel.hist.no ([158.38.50.22]:46266 "EHLO
	embla.aitel.hist.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762185AbYEVJ2b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2008 05:28:31 -0400
In-Reply-To: <482DB568.1040704@firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen wrote:
> Herbert Xu wrote:
>   
>>
>> You can continue to feed data into the pool even if it fails the
>> test.  You just keep the entropy value same as before.
>>     
>
> You could do that, but what advantage would it have? I don't think it's
> worth running the FIPS test, or rather requiring the user land daemon
> and leaving behind most of the userbase just for this.
>   
Security through obfuscation?
Someone trying to predict the RNG can do so in theory, but if
they have to keep track of network timings, disk activity, and 5 other 
things, then
chances are that they fail ofen enough even if the attack is possible 
"in theory".

Helge Hafting
