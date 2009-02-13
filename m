From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: Passive OS fingerprint xtables match.
Date: Fri, 13 Feb 2009 15:41:36 +0100 (CET)
Message-ID: <alpine.LSU.2.00.0902131541200.17695@fbirervta.pbzchgretzou.qr>
References: <20090212171245.GA15025@ioremap.net> <alpine.LSU.2.00.0902121900520.20367@fbirervta.pbzchgretzou.qr> <20090212185729.GA17896@ioremap.net> <alpine.LSU.2.00.0902122045080.670@fbirervta.pbzchgretzou.qr> <20090213130347.GD23879@ioremap.net>
 <alpine.LSU.2.00.0902131448040.9310@fbirervta.pbzchgretzou.qr> <20090213142204.GA27554@ioremap.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090213142204.GA27554@ioremap.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Friday 2009-02-13 15:22, Evgeniy Polyakov wrote:
>> >
>> >It cant, header is fixed and every option length is also fixed (and its
>> >size is checked).
>> 
>> This RFC-compliant ("An option may begin on any octet boundary.")
>> option byte stream seems to produce an odd optp value:
>> 
>> 01 02 04 05 a0 00
>> 
>> or where did I go wrong?
>
>OSF checks only MSS and timestamp options.

But still it has to jump over anything it does not check.
