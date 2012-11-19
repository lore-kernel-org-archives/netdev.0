From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: Re: [PATCH 080/493] fddi: remove use of __devexit_p
Date: Mon, 19 Nov 2012 19:16:44 +0000 (GMT)
Message-ID: <alpine.LFD.2.02.1211191912040.25230@eddie.linux-mips.org>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu> <1353349642-3677-80-git-send-email-wfp5p@virginia.edu> <alpine.LFD.2.02.1211191842180.25230@eddie.linux-mips.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: gregkh@linuxfoundation.org, netdev@vger.kernel.org
To: Bill Pemberton <wfp5p@virginia.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arrakis.dune.hu ([78.24.191.176]:54259 "EHLO
	eddie.linux-mips.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754105Ab2KSTQo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 14:16:44 -0500
Received: from localhost.localdomain ([127.0.0.1]:36353 "EHLO
        localhost.localdomain" rhost-flags-OK-OK-OK-OK)
        by eddie.linux-mips.org with ESMTP id S6825754Ab2KSTQoNJ3H2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 20:16:44 +0100
In-Reply-To: <alpine.LFD.2.02.1211191842180.25230@eddie.linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 19 Nov 2012, Maciej W. Rozycki wrote:

> > CONFIG_HOTPLUG is going away as an option so __devexit_p is no longer
> > needed.
> 
>  Shouldn't this be switching to __exit_p() instead?  Likewise all the 
> other changes concerned (i.e. s/__dev\(init\|exit\)/__\1/), for the sake 
> of drivers built into the kernel proper (yes, there are people out there 
> still doing that).  Am I missing something?
> 
>  This change scores my NAK as it stands, until updated accordingly or 
> further justified.

 I have unconfused myself now, so please replace the above with the 
following question: what about configurations (e.g. buses) that not 
support hotplug at all?  For example apart from PCI the defxx driver 
concerned here supports the TURBOchannel bus that by design does not have 
the concept of live option card removal (no such circuitry).  So should 
now the precious memory be wasted on systems that will never ever handle 
hotplug?

  Maciej
