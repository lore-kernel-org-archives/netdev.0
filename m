From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new] [Bug 12327] New: Intermittent TCP issues with =>
 2.6.27
Date: Mon, 12 Jan 2009 06:25:54 +0100
Message-ID: <496AD462.7030106@trash.net>
References: <e7c4531f0901081558n429f7275w717774dbe9ccd895@mail.gmail.com> <20090109031408.GB11336@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Dykstra <john.dykstra1@gmail.com>,
	=?ISO-8859-15?Q?Ilpo_J=E4rv?= =?ISO-8859-15?Q?inen?=
	<ilpo.jarvinen@helsinki.fi>, Netdev <netdev@vger.kernel.org>,
	bugme-daemon@bugzilla.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Speedster <speedster@haveacry.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55776 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750952AbZALF0K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 00:26:10 -0500
In-Reply-To: <20090109031408.GB11336@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Thu, Jan 08, 2009 at 05:58:11PM -0600, John Dykstra wrote:
>> I haven't unscrambled where the drop occurs in the PPPoE driver, but that's
>> presumably what changed in 2.6.27.  It seems to me that the drop is proper.
>> What's wrong is trimming the sk_buff to match the IP header while ignoring
>> the L2 header, and that's apparently been that way for a while (if I
>> understand what the reporter is running where).
>>
>> Or have I screwed up my first posting to netdev?
> 
> You've hit the nail on the head :)
> 
> The bridge netfilter is just one huge pile of crap that should
> be deleted.

Fully agreed. So far unfortunately nobody had the stomach to
get rid of this piece of junk.
