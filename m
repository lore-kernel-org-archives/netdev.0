From: Jonathan Thibault <jonathan@navigue.com>
Subject: Re: Ethernet over GRE and vlans
Date: Mon, 21 Feb 2011 10:01:19 -0500
Message-ID: <4D627E3F.8060906@navigue.com>
References: <4D2F77A8.1010700@navigue.com> <4D43A296.4040906@navigue.com> <20110221053854.GA26462@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.navigue.com ([74.117.40.3]:52481 "EHLO mail.navigue.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754270Ab1BUPBU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Feb 2011 10:01:20 -0500
In-Reply-To: <20110221053854.GA26462@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21/02/11 12:38 AM, Herbert Xu wrote:
> On Sat, Jan 29, 2011 at 12:16:06AM -0500, Jonathan Thibault wrote:
>> Is it wrong on my part to expect such behaviour from gretap devices
>> or is this simply not possible/implemented yet?
> I don't see why this shouldn't work, so it might be a bug or
> misconfiguration.  How did you setup gre1.1 and gre2.2?
>
> Cheers,
I simply ran:

vconfig add rcg0 1
ifconfig rcg0.1 up

(the gretap interface is called rcg0, obviously)

Now that I think of it I did not try to add the vlan using the 'ip link
add' command though I'm not entirely sure it would make much of a
difference.  We sort of bypassed the problem using more hardware so the
test rig is dismantled now but if you feel there really is something to
it, I can set it back up.

Thanks again,

Jonathan

P.S.:  Gretap flies...  The little atom 1.6 boards I tested this on gave
me 877Mbit/sec without breaking a sweat.
