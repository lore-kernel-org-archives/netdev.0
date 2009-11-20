From: Dhananjay Phadke <dhananjay.phadke@qlogic.com>
Subject: Re: [BUG] netxen: Stops working between 2.6.30 and 2.6.31-rc1
Date: Fri, 20 Nov 2009 10:07:53 -0800
Message-ID: <4B06DAF9.6080108@qlogic.com>
References: <20091119163908.GJ14661@jayr.de>	<7608421F3572AB4292BB2532AE89D5658B0B95BD5C@AVEXMB1.qlogic.org>	<20091119183607.GK14661@jayr.de> <m1ocmyt2ly.fsf@fess.ebiederm.org>	<20091120075258.GM14661@jayr.de> <m1tywprvl4.fsf@fess.ebiederm.org>	<4B06D234.4060600@qlogic.com> <m1d43drt0g.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jens Rosenboom <me@jayr.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Amit Salecha <amit.salecha@qlogic.com>,
	Ameen Rahman <ameen.rahman@qlogic.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:41754 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753396AbZKTSI7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 13:08:59 -0500
In-Reply-To: <m1d43drt0g.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Eric W. Biederman wrote:
> MSI-X uses the same messages on the wire is the same as MSI it is
> only the programming interface that is different.  So if MSI works and
> MSI-X does not it is not a platform problem.
> 

Sure, but firmware and driver see it differently. IMO, this points to 
some firmware issue (which is why I asked him to get right version from 
right source). All that driver did was tried to enable msi-x, from my 
testing, I can tell that both msi and msix work on all revisions of the 
nic asic, but firmware revision can make a difference. For chiprev 0x25, 
3.4.339 is the right firmware version.

Thanks,
Dhananjay
