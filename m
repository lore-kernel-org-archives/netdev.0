From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: Passive OS fingerprint xtables match (iptables part)
Date: Fri, 13 Feb 2009 14:54:25 +0100 (CET)
Message-ID: <alpine.LSU.2.00.0902131452010.9310@fbirervta.pbzchgretzou.qr>
References: <20090212171245.GA15025@ioremap.net> <alpine.LSU.2.00.0902121922280.20367@fbirervta.pbzchgretzou.qr> <20090213125215.GC23879@ioremap.net> <alpine.LSU.2.00.0902131402460.9310@fbirervta.pbzchgretzou.qr> <20090213131256.GE23879@ioremap.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:47003 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755004AbZBMNy2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Feb 2009 08:54:28 -0500
In-Reply-To: <20090213131256.GE23879@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Friday 2009-02-13 14:12, Evgeniy Polyakov wrote:
>On Fri, Feb 13, 2009 at 02:03:10PM +0100, Jan Engelhardt (jengelh@medozas.de) wrote:
>> >> >	printf("OS fingerprint match options:\n"
>> >> >		"--genre [!] string	Match a OS genre by passive fingerprinting.\n"
>> >> 
>> >> The syntax should be  [!] --genre string, that is what most
>> >> others use. Then the check_inverse call also be removed.
>> >
>> >Actually not, it has genre not Linux (Windows, Solaris, HPUX and so on).
>> 
>> It may not coincide with English grammar, but it is easier to parse.
>
>'! --genre Linux' means this option was not specified,
>'--genre ! Linux' means everything but Linux.

Well not in iptables. Not specifying an option is represented by 
voidness/absence of any string. (E.g. iptables -d 192.168.0.0/16  vs.
iptables ! -s 172.16.0.0/12 -d 192.168.0.0/16)
Also, (!(--genre == "linux")) is eqv. (--genre != "linux")
is equivalent in boolean logic  ;-)
