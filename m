From: Patrick McHardy <kaber@trash.net>
Subject: Re: Passive OS fingerprint xtables match.
Date: Wed, 18 Feb 2009 16:00:27 +0100
Message-ID: <499C228B.5000802@trash.net>
References: <20090212171245.GA15025@ioremap.net> <alpine.LSU.2.00.0902121900520.20367@fbirervta.pbzchgretzou.qr> <20090212185729.GA17896@ioremap.net> <alpine.LSU.2.00.0902122045080.670@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <zbr@ioremap.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.00.0902122045080.670@fbirervta.pbzchgretzou.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jan Engelhardt wrote:
> On Thursday 2009-02-12 19:57, Evgeniy Polyakov wrote:
>>> Are you sure it is safe to use arch-dependent types like 'int'?
>> I would be very surprised if Linux will ever run on weird arch where int
>> is not 32 bits.
> 
> If GCC had a switch to compile with I16 or I64, I could test,
> but it does not. 'long', as used in the netfilter includes,
> already bit people in pre-2.6.19, and nowadays we have that compat
> crap thing in place.. Just don't take any chance, and go the safe
> route with uint32_t.

Tons of APIs will break when the size of int changes and differs
between userspace and kernel, this is a non-realistic risk in my
opinion. I do however prefer the fixed types myself since they
make the size more visible.


