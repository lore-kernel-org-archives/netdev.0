From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 1/4] forcedeth: fix MAC address detection on network
 card (regression in 2.6.23)
Date: Fri, 9 Jan 2009 13:37:49 -0800
Message-ID: <20090109133749.59c20e40.akpm@linux-foundation.org>
References: <200901092023.n09KN72t020166@imap1.linux-foundation.org>
	<4967C05A.2070509@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	michael.pyne@kdemail.net, AAbdulla@nvidia.com, stable@kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:38917 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751726AbZAIVi1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 16:38:27 -0500
In-Reply-To: <4967C05A.2070509@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 09 Jan 2009 16:23:38 -0500
Jeff Garzik <jeff@garzik.org> wrote:

> > On Tue, 05 Feb 2008 13:20:59 -0500 Jeff Garzik <jeff@garzik.org> wrote:
> >> NAK - this fixes one set of users, and breaks a working set of users.
> >>
> >> Need to add DMI check for the specific motherboard (dmi_check_system), 
> >> and flip flag according to success/failure of that check.
> > 
> > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> 
> I'll just highlight this quoted bit for David...
> 
> I've already posted a dmi_check_system() solution too

What is the status of that?  Where is it?

> -- you just need 
> to fill in the motherboard details to fix the regression while keeping 
> others' systems working.

Can you please tell Michael what info is needed to wrap this up?  And
how he is to obtain it?

