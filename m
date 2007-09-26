From: Dave Jones <davej@redhat.com>
Subject: Re: e100 problems in .23rc8 ?
Date: Wed, 26 Sep 2007 14:18:29 -0400
Message-ID: <20070926181829.GC512@redhat.com>
References: <20070926150447.GA3761@redhat.com> <46FAA083.9020604@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:45440 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755140AbXIZSSd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Sep 2007 14:18:33 -0400
Content-Disposition: inline
In-Reply-To: <46FAA083.9020604@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 26, 2007 at 11:10:11AM -0700, Kok, Auke wrote:
 > Dave Jones wrote:
 > > Last night, I hit this bug during boot up..
 > > http://www.codemonkey.org.uk/junk/e100-2.jpg
 > > 
 > > This morning, I got a mail from a Fedora user of the same
 > > .23-rc8 based kernel that has seen a different trace
 > > also implicating e100..
 > > 
 > > http://www.codemonkey.org.uk/junk/e100.jpg
 > > 
 > > It may be that the two problems are unrelated, and it's
 > > just coincidence that both reports happen to be on an e100,
 > > but the timing is odd.  Have there been other reports
 > > of similar problems recently ?
 > 
 > there hasn't been a change to e100 in two months now - perhaps something slipped
 > into the stack that broke it? If this reproduces, could you bisect?

Yeah, I notice only 3 changes to e100 since .22
I'll see if I can reproduce the first one and bisect.

	Dave

-- 
http://www.codemonkey.org.uk
