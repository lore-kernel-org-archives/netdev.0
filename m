From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bonding-devel] BUG: bonding module can only be loaded once
Date: Wed, 10 Jun 2009 15:19:38 +0200
Message-ID: <4A2FB2EA.9040705@trash.net>
References: <20090608151127.70146505@nehalam> <200906091406.45463.arnd@arndb.de> <20090609080232.45f81833@nehalam> <4A2E80B3.6010600@trash.net> <4752.1244564082@death.nxdomain.ibm.com> <4A2E8D62.6090004@trash.net> <13521.1244568251@death.nxdomain.ibm.com> <4A2EDEB0.2080006@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, bonding-devel@lists.sf.net,
	"David S. Miller" <davem@davemloft.net>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58419 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751395AbZFJNTi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 09:19:38 -0400
In-Reply-To: <4A2EDEB0.2080006@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> Jay Vosburgh wrote:
>> Patrick McHardy <kaber@trash.net> wrote:
>>
>>> I'd expect its not the distros, but rather the applicances which might
>>> still be using this. I know a vendor I used to work for a couple of
>>> years ago just recently made the switch from 2.6.16 to a current kernel,
>>> and I'd expect that they are still using this (I can find out tommorrow
>>> if you want to know for sure). Vyatta likewise, I guess.
>>
>>     Yes, I'd like to know for sure; thanks.
> 
> I'll let you know.

They are still using the module alias method, but on a kernel slightly
older than the patch which broke this (2.6.25).
