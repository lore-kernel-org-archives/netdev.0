From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] SGISEEQ: use cached memory access to make driver work
 on IP28
Date: Sat, 01 Dec 2007 16:57:11 -0500
Message-ID: <4751D8B7.1060508@pobox.com>
References: <20071126223934.84BE7C2B26@solo.franken.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-mips@linux-mips.org,
	ralf@linux-mips.org
To: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:45654 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751218AbXLAV5O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Dec 2007 16:57:14 -0500
In-Reply-To: <20071126223934.84BE7C2B26@solo.franken.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas Bogendoerfer wrote:
> Following patch is clearly 2.6.25 material and is needed to get SGI IP28
> machines supported.
> 
> Thomas.
> 
> SGI IP28 machines would need special treatment (enable adding addtional
> wait states) when accessing memory uncached. To avoid this pain I changed
> the driver to use only cached access to memory.
> 
> Signed-off-by: Thomas Bogendoerfer <tsbogend@alpha.franken.de>

applied.  As I have noted to you previously, /please/ put extraneous 
comments /after/ a "---" separator, so that they are not copied by 
git-am (Linus's email patch import tool) into the permanent kernel 
changelog.

The above should look like:

<snip>
SGI IP28 machines would need special treatment (enable adding addtional 
wait states) when accessing memory uncached. To avoid this pain I 
changed the driver to use only cached access to memory.

Signed-off-by: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
---
Following patch is clearly 2.6.25 material and is needed to get SGI IP28 
machines supported.

Thomas.

  drivers/net/sgiseeq.c |  239 
++++++++++++++++++++++++++++++++++---------------
  1 files changed, 166 insertions(+), 73 deletions(-)
</snip>


See Documentation/SubmittingPatches for more details, in particular "14) 
The canonical patch format" or http://linux.yyz.us/patch-format.html

	Jeff


