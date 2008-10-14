From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 1/6] [NET-NEXT]qlge: Clean up and fix MSI and legacy
	irq handling.
Date: Tue, 14 Oct 2008 22:40:25 +0200
Message-ID: <20081014204025.GB9617@electric-eye.fr.zoreil.com>
References: <20081011171614.GA26384@susedev.qlogic.org> <1223745433-26440-1-git-send-email-ron.mercer@qlogic.com> <20081011205903.GA29496@electric-eye.fr.zoreil.com> <20081014201915.GA27393@susedev.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org, linux-driver@qlogic.com
To: Ron Mercer <ron.mercer@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:40988 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751504AbYJNUkg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2008 16:40:36 -0400
Content-Disposition: inline
In-Reply-To: <20081014201915.GA27393@susedev.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ron Mercer <ron.mercer@qlogic.com> :
[...]
> Your example looks much better than what I had, but it reverses the
> logic and won't work.  What I'm trying to do is skip the operation if
> we're running with MSIX-multiple interrupts AND it's not context zero.

Ok, ok.

> For all other cases we do the operation.  So fixing your suggestion it would
> be:
[snip]
> This is more compact, it's still optimized, but I think it becomes a
> little hard to read.

Remove 'unlikely' ?

> I'll gladly try it and make the change if you

Your choice. I'm fine with Roland's code as well.

-- 
Ueimor
