From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net] net: ethernet: davicom: Allow to select DM9000 for
 nios2
Date: Fri, 12 Dec 2014 10:08:03 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CA0BA8C@AcuExch.aculab.com>
References: <1418376071-28709-1-git-send-email-tklauser@distanz.ch>
 <063D6719AE5E284EB5DD2968C1650D6D1CA0BA4C@AcuExch.aculab.com>
 <20141212095717.GF16916@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Tobias Klauser' <tklauser@distanz.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:39731 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S934677AbaLLKJN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2014 05:09:13 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 22787-07 for <netdev@vger.kernel.org>;
 Fri, 12 Dec 2014 10:09:03 +0000 (GMT)
In-Reply-To: <20141212095717.GF16916@distanz.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser
> On 2014-12-12 at 10:49:13 +0100, David Laight <David.Laight@ACULAB.COM> wrote:
> > From: Tobias Klauser
> > > This chip is present on older revisions of the DE2 development kit.
> >
> > Doesn't that mean the selector should be DE2 not NIOS2.
> >
> > NIOS2 is a cpu not a board and I think this is an external peripheral
> > not something implemented in the fpga itself.
> 
> You're of course right, but since nios2 relies on device tree there is
> no notion of a specific board at compile time.
> 
> Moreover, the chip might be used on other boards (I personally know of
> at least one) based on the nios2 softcore.

And I've got several boards on my desk that have Altera fpgas and
could conceivably run linux, none of which have that chip.

Given the typical memory size constraints of such systems I can't
actually imagine anyone wanting to run anything other than a
specific cut-down kernel with a similarly cut-down userspace.

With actual hardware you might want any PCIe device (since the
fpga can be a PCIe host).
So whereas you might want almost any device, you probably want
almost none of them.

So trying to build a 'one size fits all' kernel is completely doomed.

	David
