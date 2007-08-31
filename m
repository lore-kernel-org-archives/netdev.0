From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [REVISED PATCH] 3c59x: check return of pci_enable_device()
Date: Fri, 31 Aug 2007 09:33:35 -0400
Message-ID: <46D818AF.3080802@garzik.org>
References: <200708102105.l7AL5Jje008968@imap1.linux-foundation.org> <20070814095432.GA13825@hindley.org.uk> <20070815163000.GB619@bayes.mathematik.tu-chemnitz.de> <20070816102840.GG14245@hindley.org.uk> <46D812D5.80904@garzik.org> <20070831132132.GA2647@newton.mathematik.tu-chemnitz.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mark Hindley <mark@hindley.org.uk>, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:43295 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965056AbXHaNdj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2007 09:33:39 -0400
In-Reply-To: <20070831132132.GA2647@newton.mathematik.tu-chemnitz.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Steffen Klassert wrote:
>>> commit 5cf33391eba81a49038fa8be8cbad8425b80bf7f
>>> Author: Mark Hindley <mark@hindley.org.uk>
>>> Date:   Thu Aug 16 11:26:35 2007 +0100
>>>
>>>    Check return of pci_enable_device in vortex_up().
>>>    
>>>    Also modify vortex_up to return error to callers. Handle failure of 
>>>    vortex_up in
>>>    vortex_open and vortex_resume.
>>>    
>>>    Signed-off-by: Mark Hindley <mark@hindley.org.uk>
>> Steffen, did you ACK this?  and/or going to resend it to me?

> Yes, I did. Andrew has it already in -mm, 
> I guess that he will resend it to you soon.


No need for a resend, I just wanted to make sure I wasn't stepping on 
your toes by applying this patch _instead of_ one that was going to be 
resent.

