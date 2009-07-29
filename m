From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 5/5] c/r: Add AF_UNIX support (v6)
Date: Wed, 29 Jul 2009 09:59:27 -0500
Message-ID: <20090729145927.GA8377@us.ibm.com>
References: <1248295301-30930-1-git-send-email-danms@us.ibm.com> <1248295301-30930-6-git-send-email-danms@us.ibm.com> <4A6F2D62.9040005@librato.com> <87ljm8czsf.fsf@caffeine.danplanet.com> <4A6F6B19.9010508@librato.com> <20090729133606.GB31730@us.ibm.com> <87bpn3o87o.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Oren Laadan <orenl@librato.com>, containers@lists.osdl.org,
	netdev@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>
To: Dan Smith <danms@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:57828 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751903AbZG2O7p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2009 10:59:45 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id n6TEw7YL004288
	for <netdev@vger.kernel.org>; Wed, 29 Jul 2009 08:58:07 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n6TExZNb031908
	for <netdev@vger.kernel.org>; Wed, 29 Jul 2009 08:59:44 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n6TExTYc027375
	for <netdev@vger.kernel.org>; Wed, 29 Jul 2009 08:59:30 -0600
Content-Disposition: inline
In-Reply-To: <87bpn3o87o.fsf@caffeine.danplanet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Dan Smith (danms@us.ibm.com):
> SH> At the moment you miss out on the security_socket_connect() call. 
> 
> Is that any different than the path involved when a process does a
> socketpair() call?
> 
> SH> Still your code is so customized that perhaps an explicit
> SH> security_socket_connect() call in your sock_unix_join() may be the
> SH> way to go...
> 
> So, when I do the join, I really should run the check on both the
> remote and local addresses, right?  The join operation is not really a
> connect in the sense of being one-sided...

Ok well if a join is not a connect then ignore me.

I'll set a block of time aside to take a closer look on your next
submit.

thanks,
-serge
