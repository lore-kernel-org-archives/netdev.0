From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: Bug/Warning report for the week of January 3rd, 2009
Date: Sat, 3 Jan 2009 16:20:00 -0800
Message-ID: <20090103162000.138943b3@infradead.org>
References: <20090103140332.74f39ade@infradead.org>
	<495FF769.3040205@shaw.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, x86@kernel.org, netdev@vger.kernel.org,
	tytso@mit.edu, eric@anholt.net, airlied@redhat.com
To: Robert Hancock <hancockr@shaw.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:36031 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751684AbZADASN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Jan 2009 19:18:13 -0500
In-Reply-To: <495FF769.3040205@shaw.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 03 Jan 2009 17:40:25 -0600
Robert Hancock <hancockr@shaw.ca> wrote:

> Arjan van de Ven wrote:
> > Rank 2: mtrr_trim_uncached_memory (warning)
> > 	Reported 420 times (9816 total reports)
> > 	BIOS bug (often in VMWare) where the MTRR's are set up
> > incorrectly or not at all This warning was last seen in version
> > 2.6.28, and first seen in 2.6.24. More info:
> > http://www.kerneloops.org/searchweek.php?search=mtrr_trim_uncached_memory
> 
> It would be useful if this warning dumped out some DMI BIOS
> information or something, so we could see what systems/boards this
> was commonly happening with.. 

yes it would; this is why Linus merged a patch to do exactly that for
2.6.29..........



-- 
Arjan van de Ven 	Intel Open Source Technology Centre
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
