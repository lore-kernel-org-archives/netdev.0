From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [REVISED PATCH] 3c59x: check return of pci_enable_device()
Date: Fri, 31 Aug 2007 09:32:27 -0400
Message-ID: <46D8186B.5010502@garzik.org>
References: <200708102105.l7AL5Jje008968@imap1.linux-foundation.org> <20070814095432.GA13825@hindley.org.uk> <20070815163000.GB619@bayes.mathematik.tu-chemnitz.de> <20070816102840.GG14245@hindley.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>,
	akpm@linux-foundation.org, netdev@vger.kernel.org
To: Mark Hindley <mark@hindley.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:43276 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965033AbXHaNcc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2007 09:32:32 -0400
In-Reply-To: <20070816102840.GG14245@hindley.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mark Hindley wrote:
> Revised patch for this.
> 
> Mark
> 
> 
> commit 5cf33391eba81a49038fa8be8cbad8425b80bf7f
> Author: Mark Hindley <mark@hindley.org.uk>
> Date:   Thu Aug 16 11:26:35 2007 +0100
> 
>     Check return of pci_enable_device in vortex_up().
>     
>     Also modify vortex_up to return error to callers. Handle failure of vortex_up in
>     vortex_open and vortex_resume.
>     
>     Signed-off-by: Mark Hindley <mark@hindley.org.uk>

applied


