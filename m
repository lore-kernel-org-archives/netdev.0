From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Putting for discussion "__qdisc_run" bug - strange application-dependant
 error
Date: Sun, 10 May 2009 09:33:30 +0200
Message-ID: <4A06834A.1040307@gmail.com>
References: <657221.87331.qm@web28608.mail.ukl.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Panadero Pizza <panadero_pizza@yahoo.es>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f174.google.com ([209.85.218.174]:51289 "EHLO
	mail-bw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751352AbZEJHeJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 May 2009 03:34:09 -0400
Received: by bwz22 with SMTP id 22so2074685bwz.37
        for <netdev@vger.kernel.org>; Sun, 10 May 2009 00:34:08 -0700 (PDT)
In-Reply-To: <657221.87331.qm@web28608.mail.ukl.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Panadero Pizza wrote, On 05/09/2009 09:55 PM:

> Hello netdev group,
> 
> I would like to put for discussion, if a bug in the __qdsic_run function could explain the problem I have described in my post "Kernel networking problem (>=2.6.24.7)" two days ago.
> 
> "__qdisc_run" is the last common function in the kernel traces I receive for the kernels:
> 
> 2.6.24.7
> 2.6.27.12
> 
> with a multi-threaded software, using fputc, putc, puts - calls, mixed with fflush()-calls on a remote file, opened on a cifs-handle. (Errors occur extremely seldom, although the software is running for hours - day after day)
> 
> I don't receive the error with other standard software (e.g. "dd"), writing to a file on the same cifs-handle/session and more interesting:
> The error does not occur with the afore-mentioned multi-threaded program (or any other software), using a
> 
> 2.6.16.62
> 
> kernel.
> 
> I have found that from 2.6.24.x on, the __qdisc_run function has been made preemptible and this feature has been enabled for the realization of the afore-said 2.6.24.7 and 2.6.27.12 kernels.
> 
> Though 2.6.16.62 solves my problem, I am offering participation in finding a solution for this (which should be fixed, if it is a kernel bug).
> 


Since you're suggesting the specific patch has broken this for you, could
you simply write if 2.6.24.4 (or 2.6.24.7 with "NET: Add preemption point
in qdisc_run" patch reverted) also solves your problem?

Btw., you've admitted the stack could be a problem; did you try to enable
any kernel debugging for this?

Cheers,
Jarek P.

PS: continuing the discussion within one thread and limiting line width
would make it easier to track this report.
