From: Patrick McHardy <kaber@trash.net>
Subject: Re: H.245v10+ support in nf_conntrack_h323?
Date: Tue, 01 Sep 2009 13:25:22 +0200
Message-ID: <4A9D04A2.60307@trash.net>
References: <20090901092910.GC11354@urbino.open.ch> <20090901100230.GA18651@sirena.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Andreas Jaggi <aj@open.ch>,
	Jing Min Zhao <zhaojingmin@users.sourceforge.net>,
	netdev@vger.kernel.org
To: Mark Brown <broonie@opensource.wolfsonmicro.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52096 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754068AbZIALZ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 07:25:26 -0400
In-Reply-To: <20090901100230.GA18651@sirena.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mark Brown wrote:
> On Tue, Sep 01, 2009 at 11:29:10AM +0200, Andreas Jaggi wrote:
> 
>> The videoconferencing devices use version 10 of the H.245 protocol,
>> but nf_conntrack_h323 supports version 7 (according to the comments in
>> include/linux/nf_conntrack_h323.h).
> 
>> Are there any plans to include support for version 10 (or higher) of
>> H.245 in nf_conntrack_h323?

AFAIK Jing Min isn't able to do further development of the H.323 helper.

> I'd be surprised if the H.245 version were the source of your problems
> here - the new protocol versions are backwards compatible and I don't
> remember any changes in any of the stuff that's relevant for firewall
> transit.

Good point. The helper should also log packets dropped due to parsing
errors. If you don't get any messages, I'd suggest to use the iptables
TRACE target to figure out where the packets are dropped exactly.
