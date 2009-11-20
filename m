From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [BUG] netxen: Stops working between 2.6.30 and 2.6.31-rc1
Date: Fri, 20 Nov 2009 10:21:05 -0800
Message-ID: <m16395rram.fsf@fess.ebiederm.org>
References: <20091119163908.GJ14661@jayr.de>
	<7608421F3572AB4292BB2532AE89D5658B0B95BD5C@AVEXMB1.qlogic.org>
	<20091119183607.GK14661@jayr.de> <m1ocmyt2ly.fsf@fess.ebiederm.org>
	<20091120075258.GM14661@jayr.de> <m1tywprvl4.fsf@fess.ebiederm.org>
	<4B06D234.4060600@qlogic.com> <m1d43drt0g.fsf@fess.ebiederm.org>
	<4B06DAF9.6080108@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jens Rosenboom <me@jayr.de>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	Amit Salecha <amit.salecha@qlogic.com>,
	Ameen Rahman <ameen.rahman@qlogic.com>
To: Dhananjay Phadke <dhananjay.phadke@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:55307 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753439AbZKTSVG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 13:21:06 -0500
In-Reply-To: <4B06DAF9.6080108@qlogic.com> (Dhananjay Phadke's message of "Fri\, 20 Nov 2009 10\:07\:53 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dhananjay Phadke <dhananjay.phadke@qlogic.com> writes:

> Eric W. Biederman wrote:
>> MSI-X uses the same messages on the wire is the same as MSI it is
>> only the programming interface that is different.  So if MSI works and
>> MSI-X does not it is not a platform problem.
>>
>
> Sure, but firmware and driver see it differently. IMO, this points to some
> firmware issue (which is why I asked him to get right version from right
> source). All that driver did was tried to enable msi-x, from my testing, I can
> tell that both msi and msix work on all revisions of the nic asic, but firmware
> revision can make a difference. For chiprev 0x25, 3.4.339 is the right firmware
> version.

Sorry I meant that only as a clarification, not to derail the conversation.
This does sound like a firmware mismatch issue to me as well.

Eric
