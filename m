From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: Printing the driver name as part of the netdev watchdog message
Date: Wed, 9 Jul 2008 11:50:10 -0700
Message-ID: <20080709115010.388b7b1c@infradead.org>
References: <20080708144725.5b663d19@infradead.org>
	<20080708.145738.12692130.davem@davemloft.net>
	<20080708164826.2a2d52c2@infradead.org>
	<20080708.165304.55424424.davem@davemloft.net>
	<20080708184456.52e94b93@infradead.org>
	<20080708201658.2c496b6a@speedy>
	<1215624055.5553.252.camel@localhost>
	<20080709105631.492f86bd@infradead.org>
	<1215627649.5553.265.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	swise@opengridcomputing.com, rdreier@cisco.com,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:45634 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754882AbYGISud (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2008 14:50:33 -0400
In-Reply-To: <1215627649.5553.265.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 09 Jul 2008 11:20:49 -0700
Joe Perches <joe@perches.com> wrote:

> On Wed, 2008-07-09 at 10:56 -0700, Arjan van de Ven wrote:
> > I don't like the size_t... size_t is an abstraction to deal with
> > file sizes.... but there's nothing else wrong with using an int for
> > numbers.
> 
> <pedant_mode>
> 
> o size_t is an abstraction to deal with arbitrary sizes

it's an int. abstractions hurt. sorry.

> o an unnecessary <= 0 test exists

it's not. if it was a < test going to an unsigned makes the test go
away, but it's a <=.
And signed actually catches more bugs because unsigned makes things
silent.


-- 
If you want to reach me at my work email, use arjan@linux.intel.com
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
