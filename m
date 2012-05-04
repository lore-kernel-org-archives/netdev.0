From: Joe Perches <joe@perches.com>
Subject: Re: pull request: wireless-next 2012-05-03
Date: Fri, 04 May 2012 02:42:34 -0700
Message-ID: <1336124554.1766.11.camel@joe2Laptop>
References: <20120503152206.GL9285@tuxdriver.com>
	 <20120503.130516.1008806127286088740.davem@davemloft.net>
	 <20120503.131707.112550136096227430.davem@davemloft.net>
	 <1336066186.13866.25.camel@joe2Laptop> <4FA399E1.5080708@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linville@tuxdriver.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Arend van Spriel <arend@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:32822 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753676Ab2EDJmf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 May 2012 05:42:35 -0400
In-Reply-To: <4FA399E1.5080708@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-05-04 at 10:57 +0200, Arend van Spriel wrote:
> On 05/03/2012 07:29 PM, Joe Perches wrote:
> > On Thu, 2012-05-03 at 13:17 -0400, David Miller wrote:
> >>  ...
> >> -		if (hdev->discovery.type == DISCOV_TYPE_INTERLEAVED) {
> >> +		if (hdev->discovery.type == DISCOV_TYPE_INTERLEAVED &&
> >> +				hdev->discovery.state == DISCOVERY_FINDING) {
> >>
> >> Really, we went through this a million times very recently and I'm
> >> not pulling anything into my tree that has garbage like this in it.
> > 
> > Perhaps the bluetooth folk can adopt using
> > 
> > scripts/checkpatch.pl --strict
> > 
> > or maybe checkpatch could be changed to use
> > --strict on patches in net and drivers/net
> > automatically.
> 
> When the --strict option was added it

--strict was added to checkpatch in 2007
to quiet some of the more controversial
output messages.

> So why not do --strict by default and get rid of the option flag.

Some subsystem maintainers would again
complain about checkpatch output verbosity.

Maybe some of the less controversial CHK 
tests can be changed to WARN.

Still, who really cares whether or not
multiline indentation is aligned after an
open parenthesis or on a tabstop?

Ted Ts'o had an idea awhile back about
adding .checkpatch config files to every
directory that had specific formatting
wants.  That might work too.

https://lkml.org/lkml/2012/3/13/662
