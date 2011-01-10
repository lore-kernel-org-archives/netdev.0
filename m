From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: [PATCH] Cleanup include/net/tcp.h include-files and
 coding-style
Date: Mon, 10 Jan 2011 08:30:24 -0800
Message-ID: <20110110083024.ab3bad25.rdunlap@xenotime.net>
References: <1294606534-28522-1-git-send-email-christoph.paasch@uclouvain.be>
	<201101101244.24932.christoph.paasch@uclouvain.be>
	<20110110075032.e38955ef.rdunlap@xenotime.net>
	<201101101724.46023.christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: christoph.paasch@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([72.52.115.56]:42817 "HELO xenotime.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753153Ab1AJQa0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jan 2011 11:30:26 -0500
Received: from chimera.site ([173.50.240.230]) by xenotime.net for <netdev@vger.kernel.org>; Mon, 10 Jan 2011 08:30:24 -0800
In-Reply-To: <201101101724.46023.christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 10 Jan 2011 17:24:45 +0100 Christoph Paasch wrote:

> 
> On Monday, January 10, 2011 wrote Randy Dunlap:
> > Documentation/SubmitChecklist, #1:
> > 
> > 1: If you use a facility then #include the file that defines/declares
> >    that facility.  Don't depend on other header files pulling in ones
> >    that you use.
> Ok, great. That was the answer I was looking for.
> 
> So, there is a clear rule that defines the #include-policy.
> 
> Now, should the missing #include's be added, or not?
> 
> Alexey Dobriyan is against it, as he says in one of his previous mails.
> And, I'm nearly sure that the rule is not respected in plenty of other files 
> of the Linux Kernel.

If a build fails on any $architecture due to a missing header file, then
the header file should be added.

If you just want to fix source files that are missing header files, then
the patches should be accepted, even if they are not "needed" in some
strong sense of that word.

Adding the header files adds documentation that some interface from that
header file is being used and it prevents failures that would happen
if an indirect #include were removed, so it's a good practice, but sure,
there are plenty of places that miss this.  It was added as Rule #1
(explicity as Rule __#1__) due to so many build errors due to this
that were occurring in linux-next trees.


---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
