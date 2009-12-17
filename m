From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Bugme-new] [Bug 14794] New: IP address assigned by DHCP is
  dropped after ~40 seconds
Date: Thu, 17 Dec 2009 22:44:44 +0100
Message-ID: <4B2AA64C.50709@gmail.com>
References: <bug-14794-10286@http.bugzilla.kernel.org/>	<20091216154713.f082e7cf.akpm@linux-foundation.org>	<4B2A9A40.90203@freemail.hu> <20091217132451.b168a796.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-1?Q?N=E9meth_M=E1rton?= <nm127@freemail.hu>,
	Mike Galbraith <efault@gmx.de>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Ingo Molnar <mingo@elte.hu>, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f221.google.com ([209.85.220.221]:55980 "EHLO
	mail-fx0-f221.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765419AbZLQVpV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 16:45:21 -0500
Received: by fxm21 with SMTP id 21so2330158fxm.21
        for <netdev@vger.kernel.org>; Thu, 17 Dec 2009 13:45:20 -0800 (PST)
In-Reply-To: <20091217132451.b168a796.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote, On 12/17/2009 10:24 PM:

> On Thu, 17 Dec 2009 21:53:20 +0100
> N__meth M__rton <nm127@freemail.hu> wrote:
> 
>> Hi,
>>
>> I bisected the problem, see http://bugzilla.kernel.org/show_bug.cgi?id=14794
>> for details. Any idea what is the relation between this problem and the found
>> patch?
>>
> 
> Please don't update this report via the bugillla interface.  See
> "(switched to email.  Please respond via emailed reply-to-all, not via
> the bugzilla web interface)."
> 
> : 61cbe54d9479ad98283b2dda686deae4c34b2d59 is the first bad commit
> : commit 61cbe54d9479ad98283b2dda686deae4c34b2d59
> : Author: Mike Galbraith <efault@gmx.de>
> : Date:   Wed Sep 9 15:41:37 2009 +0200
> :
> :    sched: Keep kthreads at default priority
> 
> Strange.  Might be a timing thing bu a) I doubt if any kernel threads
> are involved in maintaining a DHCP lease and b) even if they were, such
> a race wouldn't be this repeatable.
> 

"Removes kthread/workqueue priority boost[...]" - if there could be
workqueues involved - maybe something with link-watch?

Jarek P.
