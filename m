From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch (for 2.6.25?) 1/3] e100: do suspend/shutdown like e1000
Date: Tue, 4 Mar 2008 15:33:30 -0800
Message-ID: <20080304153330.fd224258.akpm@linux-foundation.org>
References: <200803042258.m24MwfoZ001397@imap1.linux-foundation.org>
	<47CDD54A.60101@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, arvidjaar@mail.ru
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:59851 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755173AbYCDXix (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 18:38:53 -0500
In-Reply-To: <47CDD54A.60101@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 04 Mar 2008 15:03:38 -0800
"Kok, Auke" <auke-jan.h.kok@intel.com> wrote:

> akpm@linux-foundation.org wrote:
> > From: "Kok, Auke" <auke-jan.h.kok@intel.com>
> > 
> > This fixes a "trying to free already free IRQ" message and simplifies the
> > shutdown/suspend code by re-using already existing code when going to
> > suspend.  The code is now symmetric with e100_resume.
> > 
> > Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> > Tested-by: Andrey Borzenkov <arvidjaar@mail.ru>
> > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> 
> 
> This should already be in jeff's inbox ...
> 

It's been two weeks nearly - Jeff's inbox might have sprunk a leak ;)

There are lots of leaky inboxes - I have just finished spraying nearly 200
dribbles at various maintainers.

