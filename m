From: Greg KH <gregkh@suse.de>
Subject: Re: [2/2] 2.6.22-rc4: known regressions with patches v3
Date: Wed, 13 Jun 2007 13:35:02 -0700
Message-ID: <20070613203501.GA5708@suse.de>
References: <46704B5D.5020106@googlemail.com> <46704C4D.5010803@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>, linux-wireless@vger.kernel.org,
	Samuel Ortiz <samuel@sortiz.org>,
	Andrey Borzenkov <arvidjaar@mail.ru>,
	Bjorn Helgaas <bjorn.helgaas@hp.com>,
	Stephen Smalley <sds@tycho.nsa.gov>,
	James Morris <jmorris@namei.org>,
	Eric Paris <eparis@parisplace.org>,
	Ingo Molnar <mingo@elte.hu>,
	Paulo Pereira <pfmp.404@gmail.com>,
	Alan Stern <stern@rowland.harvard.edu>
To: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:59009 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752744AbXFMUg0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2007 16:36:26 -0400
Content-Disposition: inline
In-Reply-To: <46704C4D.5010803@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 13, 2007 at 09:58:05PM +0200, Michal Piotrowski wrote:
>  USB
> 
>  Subject    : list_add corruption. prev->next should be next (f7d28794), but 
>  was f0df8ed4 (prev=f0df8ed4) Kernel Bug at lib/list_debug.c:33
>  References : http://bugzilla.kernel.org/show_bug.cgi?id=8561
>  Submitter  : Paulo Pereira <pfmp.404@gmail.com>
>  Handled-By : Alan Stern <stern@rowland.harvard.edu>
>  Patch      : http://bugzilla.kernel.org/show_bug.cgi?id=8561#c8
>  Status     : patch was suggested

I'm pretty sure this wasn't a "regression" and was always there, and
that the proposed patch did fix the solution, right Paulo and Alan?

thanks,

greg k-h
