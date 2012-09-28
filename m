From: Miroslav Lichvar <mlichvar@redhat.com>
Subject: Re: [PATCH RFC net-next 1/1] ptp: add an ioctl to compare PHC time
 with system time
Date: Fri, 28 Sep 2012 10:50:31 +0200
Message-ID: <20120928085031.GC29438@localhost>
References: <cover.1348768886.git.richardcochran@gmail.com>
 <f0c20e2d1a303b0247b1e0e0def19f131de162ff.1348768886.git.richardcochran@gmail.com>
 <20120928075303.GB29438@localhost>
 <20120928082638.GB17636@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Jacob Keller <jacob.e.keller@intel.com>,
	John Stultz <john.stultz@linaro.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60430 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753736Ab2I1Iui (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Sep 2012 04:50:38 -0400
Content-Disposition: inline
In-Reply-To: <20120928082638.GB17636@netboy.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 28, 2012 at 10:26:38AM +0200, Richard Cochran wrote:
> I am guessing it would be possible to synchronize two PHC devices to
> within a few microseconds this way. Probably that is not good enough
> to implement a boundary clock, for example, so I have my doubts about
> the utility of this. 

I think with two identical PHCs the error would be much smaller, even
if the two fastest consecutive readings took together ~5 microseconds.
The error could be measured with a short cable connecting the two ports
and compared the TX and RX timestamps, and compensated in the
software if it's significant.

> But in any case, it is possible, and I think that
> feature can wait for now.

Ok, thanks.

-- 
Miroslav Lichvar
