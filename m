From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Multicast Routing Kernel option?
Date: Fri, 15 Aug 2008 16:13:24 +0200
Message-ID: <87tzdmxt6j.fsf@basil.nowhere.org>
References: <loom.20080815T073349-129@post.gmane.org>
	<124178.76775.qm@web31502.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Daniel Ng <daniel_ng11@lycos.com>
To: imipak@yahoo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:42754 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753933AbYHOON1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2008 10:13:27 -0400
In-Reply-To: <124178.76775.qm@web31502.mail.mud.yahoo.com> (Jonathan Day's message of "Fri, 15 Aug 2008 01:41:51 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jonathan Day <imipak@yahoo.com> writes:

> They could, I guess, but context switches are expensive (think 20ms
> from kernel to user, and same in reverse)

40ms for a system call? That would be really horrible if it really
were that slow. Fortunately it's not. A Core2 (Merom) here can do a
very simple system call roundtrip (getppid()) in ~570 cycles, that is
at 2Ghz less than 300ns. You are roughly 5 orders of magnitude off.
 
-Andi
