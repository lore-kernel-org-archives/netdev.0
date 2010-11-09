From: Patrick McHardy <kaber@trash.net>
Subject: Re: Netlink limitations
Date: Tue, 09 Nov 2010 10:27:34 +0100
Message-ID: <4CD91406.4000603@trash.net>
References: <alpine.LNX.2.01.1011071743070.21289@obet.zrqbmnf.qr> <4CD6DF37.6010800@trash.net> <20101108151635.GA20629@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Jan Engelhardt <jengelh@medozas.de>,
	"David S. Miller" <davem@davemloft.net>, pablo@netfilter.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50935 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753630Ab0KIJ1v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Nov 2010 04:27:51 -0500
In-Reply-To: <20101108151635.GA20629@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 08.11.2010 16:16, schrieb Thomas Graf:
> On Sun, Nov 07, 2010 at 06:17:43PM +0100, Patrick McHardy wrote:
>> On 07.11.2010 17:44, Jan Engelhardt wrote:
>>> ...
> 
>> That's somewhat similar to the nlattr32 idea, but a length of 0 makes
>> more sense since that's currently not used. In that case the length
>> would be read from a second length field which has 32 bits.
> 
> I agree. This makes perfect sense. I was just thinking wheter we want
> to encode more information into the attribute header if we extend it
> anyways.

What kind of additional information are you thinking about?
