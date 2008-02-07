From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [bisected] Re: [bug] networking broke, ssh: connect to port
	22: Protocol error
Date: Thu, 7 Feb 2008 12:44:44 +0100
Message-ID: <20080207114444.GA387@elte.hu>
References: <20080206133506.GA21202@elte.hu> <657224.72762.qm@web36615.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Casey Schaufler <casey@schaufler-ca.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:60392 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754293AbYBGLpD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Feb 2008 06:45:03 -0500
Content-Disposition: inline
In-Reply-To: <657224.72762.qm@web36615.mail.mud.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Casey Schaufler <casey@schaufler-ca.com> wrote:

> > So unlike some other security modules like SELINUX, enabling SMACK 
> > breaks un-aware userspace and breaks TCP networking?
> > 
> > I dont think that's expected behavior - and i'd definitely like to 
> > enable SMACK in automated tests to check for regressions, etc.
> 
> As Stephen mentions later, Smack uses CIPSO. sshd does not like any IP 
> options because of traceroute, and must be built with that check 
> disabled with the current Smack version. I have been looking at using 
> unlabeled packets for the "ambient" label, it appears that doing so 
> would make life simpler. I will get right on it.

ok - feel free to send me any patches to test.

	Ingo
