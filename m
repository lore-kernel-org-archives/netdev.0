From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [NET] 3c59x: Fix several modpost warnings
Date: Fri, 09 Mar 2007 11:57:30 -0500
Message-ID: <45F191FA.2070205@garzik.org>
References: <20070308153316.GA17301@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:57892 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1767411AbXCIQ5d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Mar 2007 11:57:33 -0500
In-Reply-To: <20070308153316.GA17301@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ralf Baechle wrote:
> WARNING: drivers/net/3c59x.o - Section mismatch: reference to .init.text: from .text between 'vortex_eisa_probe' (at offset 0x4580) and 'vortex_eisa_remove'
> WARNING: drivers/net/3c59x.o - Section mismatch: reference to .init.text: from .text between 'vortex_eisa_probe' (at offset 0x4584) and 'vortex_eisa_remove'
> WARNING: drivers/net/3c59x.o - Section mismatch: reference to .init.text: from .text between 'vortex_eisa_probe' (at offset 0x4588) and 'vortex_eisa_remove'
> WARNING: drivers/net/3c59x.o - Section mismatch: reference to .init.text: from .text between 'vortex_eisa_probe' (at offset 0x458c) and 'vortex_eisa_remove'
> 
> Fixed by:
> 
>  o move definition of vortex_eisa_driver below the functions it references.
>  o remove now unnecessary prototypes for vortex_eisa_probe and
>    vortex_eisa_remove.
>  o Make vortex_eisa_probe an __init function.
>  o Make vortex_eisa_remove a __devexit function.
>  o Wrap vortex_eisa_driver reference to vortex_eisa_remove with
>    __devexit_p().
> 
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>
> 
>  drivers/net/3c59x.c |   28 +++++++++++++---------------
>  1 file changed, 13 insertions(+), 15 deletions(-)

applied this and ibmtr patch


