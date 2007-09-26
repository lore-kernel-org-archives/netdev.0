From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: e100 problems in .23rc8 ?
Date: Wed, 26 Sep 2007 11:10:11 -0700
Message-ID: <46FAA083.9020604@intel.com>
References: <20070926150447.GA3761@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:28744 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754308AbXIZSKW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Sep 2007 14:10:22 -0400
In-Reply-To: <20070926150447.GA3761@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave Jones wrote:
> Last night, I hit this bug during boot up..
> http://www.codemonkey.org.uk/junk/e100-2.jpg
> 
> This morning, I got a mail from a Fedora user of the same
> .23-rc8 based kernel that has seen a different trace
> also implicating e100..
> 
> http://www.codemonkey.org.uk/junk/e100.jpg
> 
> It may be that the two problems are unrelated, and it's
> just coincidence that both reports happen to be on an e100,
> but the timing is odd.  Have there been other reports
> of similar problems recently ?

there hasn't been a change to e100 in two months now - perhaps something slipped
into the stack that broke it? If this reproduces, could you bisect?

Auke
