From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: Re: [PATCH 11/34]bnx2x: Endianness issues
Date: Mon, 19 Jan 2009 11:54:38 -0800
Message-ID: <1232394878.13386.1.camel@brick>
References: <1231951395.11301.132.camel@lb-tlvb-eliezer>
	 <20090118165908.GA11345@infradead.org>
	 <1232360018.29087.3.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Christoph Hellwig <hch@infradead.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eilon Greenstein <eilong@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.249]:56098 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753198AbZASUEJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 15:04:09 -0500
Received: by an-out-0708.google.com with SMTP id c5so242431anc.8
        for <netdev@vger.kernel.org>; Mon, 19 Jan 2009 12:04:05 -0800 (PST)
In-Reply-To: <1232360018.29087.3.camel@lb-tlvb-eliezer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-01-19 at 12:13 +0200, Eilon Greenstein wrote:
> On Sun, 2009-01-18 at 08:59 -0800, Christoph Hellwig wrote:
> > On Wed, Jan 14, 2009 at 06:43:15PM +0200, Eilon Greenstein wrote:
> > > Adding missing le_to_cpu and disabling wrong HW endianity flag (the two complete
> > > each other)
> > 
> > Did you run sparse over the driver to verify you've sorted out all
> > endianess issues?
> > 
> No - those are errors with the FW/HW and not general issues. When
> running sparse with CF=-D__CHECK_ENDIAN__ I get "too many warnings"...
> So I cannot send the patch right now. I will definitely add it to my
> queue and I hope to sort it out soon.
> 
> Eilon

I'll take a look as well.  BTW, make sure you don't have the trace all
if statements tracer enabled in your config or you'll be drowned in
shadowed variable warnings and won't be able to see anything from your
driver.

Harvey

