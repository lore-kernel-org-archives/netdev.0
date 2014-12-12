From: Tobias Klauser <tklauser@distanz.ch>
Subject: Re: [PATCH net] net: ethernet: davicom: Allow to select DM9000 for
 nios2
Date: Fri, 12 Dec 2014 11:17:21 +0100
Message-ID: <20141212101721.GG16916@distanz.ch>
References: <1418376071-28709-1-git-send-email-tklauser@distanz.ch>
 <063D6719AE5E284EB5DD2968C1650D6D1CA0BA4C@AcuExch.aculab.com>
 <20141212095717.GF16916@distanz.ch>
 <063D6719AE5E284EB5DD2968C1650D6D1CA0BA8C@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sym2.noone.org ([178.63.92.236]:33892 "EHLO sym2.noone.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965792AbaLLKR0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Dec 2014 05:17:26 -0500
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CA0BA8C@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014-12-12 at 11:08:03 +0100, David Laight <David.Laight@ACULAB.COM> wrote:
> From: Tobias Klauser
> > On 2014-12-12 at 10:49:13 +0100, David Laight <David.Laight@ACULAB.COM> wrote:
> > > From: Tobias Klauser
> > > > This chip is present on older revisions of the DE2 development kit.
> > >
> > > Doesn't that mean the selector should be DE2 not NIOS2.
> > >
> > > NIOS2 is a cpu not a board and I think this is an external peripheral
> > > not something implemented in the fpga itself.
> > 
> > You're of course right, but since nios2 relies on device tree there is
> > no notion of a specific board at compile time.
> > 
> > Moreover, the chip might be used on other boards (I personally know of
> > at least one) based on the nios2 softcore.
> 
> And I've got several boards on my desk that have Altera fpgas and
> could conceivably run linux, none of which have that chip.
> 
> Given the typical memory size constraints of such systems I can't
> actually imagine anyone wanting to run anything other than a
> specific cut-down kernel with a similarly cut-down userspace.
> 
> With actual hardware you might want any PCIe device (since the
> fpga can be a PCIe host).
> So whereas you might want almost any device, you probably want
> almost none of them.
> 
> So trying to build a 'one size fits all' kernel is completely doomed.

I completely agree. However I don't see how this has anything to do with
this patch, as it only allows to select the driver but doesn't do so by
default.
