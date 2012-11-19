From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: Re: [PATCH 080/493] fddi: remove use of __devexit_p
Date: Mon, 19 Nov 2012 18:49:00 +0000 (GMT)
Message-ID: <alpine.LFD.2.02.1211191842180.25230@eddie.linux-mips.org>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu> <1353349642-3677-80-git-send-email-wfp5p@virginia.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: gregkh@linuxfoundation.org, netdev@vger.kernel.org
To: Bill Pemberton <wfp5p@virginia.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arrakis.dune.hu ([78.24.191.176]:54203 "EHLO
	eddie.linux-mips.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754445Ab2KSStC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 13:49:02 -0500
Received: from localhost.localdomain ([127.0.0.1]:36296 "EHLO
        localhost.localdomain" rhost-flags-OK-OK-OK-OK)
        by eddie.linux-mips.org with ESMTP id S6825746Ab2KSStAzdcCx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 19:49:00 +0100
In-Reply-To: <1353349642-3677-80-git-send-email-wfp5p@virginia.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 19 Nov 2012, Bill Pemberton wrote:

> CONFIG_HOTPLUG is going away as an option so __devexit_p is no longer
> needed.

 Shouldn't this be switching to __exit_p() instead?  Likewise all the 
other changes concerned (i.e. s/__dev\(init\|exit\)/__\1/), for the sake 
of drivers built into the kernel proper (yes, there are people out there 
still doing that).  Am I missing something?

 This change scores my NAK as it stands, until updated accordingly or 
further justified.

  Maciej
