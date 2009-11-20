From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [BUG] netxen: Stops working between 2.6.30 and 2.6.31-rc1
Date: Fri, 20 Nov 2009 09:43:59 -0800
Message-ID: <m1d43drt0g.fsf@fess.ebiederm.org>
References: <20091119163908.GJ14661@jayr.de>
	<7608421F3572AB4292BB2532AE89D5658B0B95BD5C@AVEXMB1.qlogic.org>
	<20091119183607.GK14661@jayr.de> <m1ocmyt2ly.fsf@fess.ebiederm.org>
	<20091120075258.GM14661@jayr.de> <m1tywprvl4.fsf@fess.ebiederm.org>
	<4B06D234.4060600@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jens Rosenboom <me@jayr.de>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	Amit Salecha <amit.salecha@qlogic.com>,
	Ameen Rahman <ameen.rahman@qlogic.com>
To: Dhananjay Phadke <dhananjay.phadke@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:58953 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751547AbZKTRn4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 12:43:56 -0500
In-Reply-To: <4B06D234.4060600@qlogic.com> (Dhananjay Phadke's message of "Fri\, 20 Nov 2009 09\:30\:28 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dhananjay Phadke <dhananjay.phadke@qlogic.com> writes:

>> Weird. MSI's definitely weren't disabled.  Looking a little farther at
>> your quoted setup MSI work on your board.  This is definitely
>> something specific to the driver.  Except for a few initialization
>> races that are an issue for bonding I am running 2.6.31 just fine.
>
>
> Jens,
>
> Even if /proc/interrupt says PCI-MSI in both cases, single interrupt case is msi
> vs. 4 vector case is msi-x. To confirm that msi-x doesn't work with your
> card/machine, you can still stay on 2.6.31 and set use_msi_x=0 in
> netxen_nic_main.c.
>
> I had tried to make a available a module param to disable msi/msi-x for
> platforms where msi-x doesn't work cleanly, but it was declined by David Miller,
> et al.

MSI-X uses the same messages on the wire is the same as MSI it is
only the programming interface that is different.  So if MSI works and
MSI-X does not it is not a platform problem.

Eric
