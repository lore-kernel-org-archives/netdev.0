From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: Passive OS fingerprint xtables match (iptables part)
Date: Fri, 13 Feb 2009 14:03:10 +0100 (CET)
Message-ID: <alpine.LSU.2.00.0902131402460.9310@fbirervta.pbzchgretzou.qr>
References: <20090212171245.GA15025@ioremap.net> <alpine.LSU.2.00.0902121922280.20367@fbirervta.pbzchgretzou.qr> <20090213125215.GC23879@ioremap.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090213125215.GC23879@ioremap.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Friday 2009-02-13 13:52, Evgeniy Polyakov wrote:
>On Thu, Feb 12, 2009 at 07:26:53PM +0100, Jan Engelhardt (jengelh@medozas.de) wrote:
>> >static void osf_help(void)
>> >{
>> >	printf("OS fingerprint match options:\n"
>> >		"--genre [!] string	Match a OS genre by passive fingerprinting.\n"
>> 
>> The syntax should be  [!] --genre string, that is what most
>> others use. Then the check_inverse call also be removed.
>
>Actually not, it has genre not Linux (Windows, Solaris, HPUX and so on).

It may not coincide with English grammar, but it is easier to parse.
