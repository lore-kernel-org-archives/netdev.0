From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [BUG] netxen: Stops working between 2.6.30 and 2.6.31-rc1
Date: Thu, 19 Nov 2009 17:19:05 -0800
Message-ID: <m1ocmyt2ly.fsf@fess.ebiederm.org>
References: <20091119163908.GJ14661@jayr.de>
	<7608421F3572AB4292BB2532AE89D5658B0B95BD5C@AVEXMB1.qlogic.org>
	<20091119183607.GK14661@jayr.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dhananjay Phadke <dhananjay.phadke@qlogic.com>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	Amit Salecha <amit.salecha@qlogic.com>
To: Jens Rosenboom <me@jayr.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:49660 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756983AbZKTBTH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2009 20:19:07 -0500
In-Reply-To: <20091119183607.GK14661@jayr.de> (Jens Rosenboom's message of "Thu\, 19 Nov 2009 19\:36\:07 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jens Rosenboom <me@jayr.de> writes:

> On Thu, Nov 19, 2009 at 10:07:21AM -0800, Dhananjay Phadke wrote:
>> > My netxen 10G card stops working somewhere between 2.6.30 and 2.6.31-rc1.
>> > With the
>> > newer kernel I can see packets been received on the switch it is
>> > connected to, but
>> > the kernel doesn't report any sent packets in the interface counters and
>> > nothing
>> > is being received either.
>> > 
>> > I've tried to bisect this, but only seems the end up with kernels that do
>> > not boot
>> > at all because some SCSI stuff goes bad.
>> 
>> Any particular reason for using -rc1 kernel and not 2.6.31 stable kernel?
>
> Sorry, I forgot to mention that all later kernels that I tested
> including 2.6.31 and the current net-2.6 also fail, so the badness 
> comes in somewhere in between 2.6.30 and 2.6.31-rc1.
>
> I also noticed that the newer kernel allocate four interrupts for the
> card instead of only one, but none of them seem to get triggered, the
> /proc/interrupts counters all stay at zero.

Hmm.  Have you tried disabling msi's? aka putting nomsi on the kernel
command line.

If you aren't getting interrupts it might be that your board simply
has problems with receiving msi interrupts.  That at least used to
be common.

Eric
