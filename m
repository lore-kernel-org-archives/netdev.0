From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] natsemi: make cable length magic configurable
Date: Mon, 16 Jul 2012 22:22:04 -0700 (PDT)
Message-ID: <20120716.222204.1767763009548524229.davem@davemloft.net>
References: <1342441581.4165.235.camel@amber.site>
	<1342444134.2523.4.camel@bwh-desktop.uk.solarflarecom.com>
	<20120716135740.GB22600@sirena.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, jdelvare@suse.de,
	netdev@vger.kernel.org, thockin@hockin.org, okir@suse.de
To: broonie@opensource.wolfsonmicro.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46082 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750847Ab2GQFWF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 01:22:05 -0400
In-Reply-To: <20120716135740.GB22600@sirena.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Date: Mon, 16 Jul 2012 14:57:40 +0100

> On Mon, Jul 16, 2012 at 02:08:54PM +0100, Ben Hutchings wrote:
>> On Mon, 2012-07-16 at 14:26 +0200, Jean Delvare wrote:
> 
>> > Furthermore I don't quite get why we can't just go with the module
>> > parameter. As I understand it, this is a crappy driver for crappy, rare
>> > hardware. The driver already has a module parameter to work around a
>> > hardware bug (dspcfg_workaround), I don't quite see why adding a second
>> > one would be a problem. At least it is consistent.
> 
>> David can be quite insistent about finding an alternative to module
>> parameters.
> 
> The hardware isn't that rare or bad - it's pretty widely deployed in
> 100Mbit systems (including lots of embedded ones) and performs well for
> the systems it's targetting.  You'd not use it for a modern server but
> if what you need is 100M it's a fairly good part.

I don't want to hear any excuses for not implementing a configuration
interface properly.  I'm sure if I allowed it, everyone would be able
to come up with a special set of circumstances which justified the
module parameter.

Sorry, no.
