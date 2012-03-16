From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: setns question
Date: Fri, 16 Mar 2012 16:36:40 -0700
Message-ID: <m1aa3g86ev.fsf@fess.ebiederm.org>
References: <CADDf=MSHZUeq8V9jx9ybofCu9m=_L2vYaNRhFEd9EL0AVi5O4w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: yao zhao <yao.development@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:58366 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1162050Ab2CPXdP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2012 19:33:15 -0400
In-Reply-To: <CADDf=MSHZUeq8V9jx9ybofCu9m=_L2vYaNRhFEd9EL0AVi5O4w@mail.gmail.com>
	(yao zhao's message of "Thu, 15 Mar 2012 09:50:36 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

yao zhao <yao.development@gmail.com> writes:

> Hi Eric,
>
> Can I ask some questions about setns?
>
> 1.setns is complete > 3.0 but right now it doesn't support mnt and pid
> yet.

Correct.  I need to find some time and get those patches merged.

> 2.setns can set a process' uts, net, ipc to different namespace, 

Yes.
> it is not fd based, right?
The argument to setns is a fd.

> 3.is this supported:
>      ProcessA's uts == ProcessB's uts
>      ProcessA's ipc == ProcessC's ipc
>      ProcessA's net == ProcessD's net

Yes.  Even without setns that is supported.

I suggest if you want more details you read the code.

Eric
