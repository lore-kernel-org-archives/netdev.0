From: Frederik Deweerdt <deweerdt@free.fr>
Subject: Re: Strange soft lockup detected message (looks like spin_lock bug in pcnet32)
Date: Fri, 4 May 2007 16:33:26 +0200
Message-ID: <20070504143326.GD24769@slug>
References: <20070503203143.GA8753@csclub.uwaterloo.ca> <20070504141024.GB8753@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:21262 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755359AbXEDOe0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2007 10:34:26 -0400
Received: by ug-out-1314.google.com with SMTP id 44so658618uga
        for <netdev@vger.kernel.org>; Fri, 04 May 2007 07:34:25 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20070504141024.GB8753@csclub.uwaterloo.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 04, 2007 at 10:10:24AM -0400, Lennart Sorensen wrote:
> On Thu, May 03, 2007 at 04:31:43PM -0400, Lennart Sorensen wrote:
[...]
> Should line 2563 be a spin_lock_irqsave instead along with the
> appropriate unluck later?
IIRC, when you enable lockdep, it will complain about spinlocks used in
an invalid context.

Regards,
Frederik
> 
> --
> Len Sorensen
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 
