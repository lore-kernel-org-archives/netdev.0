From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH 11/34]bnx2x: Endianness issues
Date: Mon, 19 Jan 2009 12:13:38 +0200
Message-ID: <1232360018.29087.3.camel@lb-tlvb-eliezer>
References: <1231951395.11301.132.camel@lb-tlvb-eliezer>
 <20090118165908.GA11345@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: "Christoph Hellwig" <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3056 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756438AbZASKOg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jan 2009 05:14:36 -0500
In-Reply-To: <20090118165908.GA11345@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2009-01-18 at 08:59 -0800, Christoph Hellwig wrote:
> On Wed, Jan 14, 2009 at 06:43:15PM +0200, Eilon Greenstein wrote:
> > Adding missing le_to_cpu and disabling wrong HW endianity flag (the two complete
> > each other)
> 
> Did you run sparse over the driver to verify you've sorted out all
> endianess issues?
> 
No - those are errors with the FW/HW and not general issues. When
running sparse with CF=-D__CHECK_ENDIAN__ I get "too many warnings"...
So I cannot send the patch right now. I will definitely add it to my
queue and I hope to sort it out soon.

Eilon


