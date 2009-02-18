From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: Passive OS fingerprint xtables match.
Date: Wed, 18 Feb 2009 16:28:58 +0100 (CET)
Message-ID: <alpine.LSU.2.00.0902181627220.8034@fbirervta.pbzchgretzou.qr>
References: <20090212171245.GA15025@ioremap.net> <alpine.LSU.2.00.0902121900520.20367@fbirervta.pbzchgretzou.qr> <20090212185729.GA17896@ioremap.net> <alpine.LSU.2.00.0902122045080.670@fbirervta.pbzchgretzou.qr> <499C228B.5000802@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Evgeniy Polyakov <zbr@ioremap.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <499C228B.5000802@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Wednesday 2009-02-18 16:00, Patrick McHardy wrote:
> Jan Engelhardt wrote:
>> On Thursday 2009-02-12 19:57, Evgeniy Polyakov wrote:
>>>> Are you sure it is safe to use arch-dependent types like 'int'?
>>> I would be very surprised if Linux will ever run on weird arch where int
>>> is not 32 bits.
>>
>> If GCC had a switch to compile with I16 or I64, I could test,
>> but it does not. 'long', as used in the netfilter includes,
>> already bit people in pre-2.6.19, and nowadays we have that compat
>> crap thing in place.. Just don't take any chance, and go the safe
>> route with uint32_t.
>
> Tons of APIs will break when the size of int changes and differs
> between userspace and kernel, this is a non-realistic risk in my
> opinion.

It is very realistic. Compilers for Microsoft DOS/Windows used to
map 'int' to a 16-bit type, and they changed that when 32-bit
became modern. Don't you think that too broke lots of stuff?
