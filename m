From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC][PATCH] ns: Syscalls for better namespace sharing control.
Date: Fri, 26 Feb 2010 15:13:47 -0800
Message-ID: <m1mxyvtwt0.fsf@fess.ebiederm.org>
References: <4B4F24AC.70105@trash.net> <4B4F3A50.1050400@trash.net>
	<1263490403.23480.109.camel@bigi> <4B50403A.6010507@trash.net>
	<1263568754.23480.142.camel@bigi> <m13a0tf17t.fsf@fess.ebiederm.org>
	<1266875729.3673.12.camel@bigi> <m1wry46es9.fsf@fess.ebiederm.org>
	<1266931623.3973.643.camel@bigi> <m1iq9ocafv.fsf@fess.ebiederm.org>
	<1266934817.3973.654.camel@bigi> <m1r5obbu2w.fsf@fess.ebiederm.org>
	<1266966581.3973.675.camel@bigi> <m1pr3t2fvl.fsf_-_@fess.ebiederm.org>
	<4B883987.6090408@parallels.com> <m1bpfbwuze.fsf@fess.ebiederm.org>
	<4B883E6F.1060907@parallels.com> <m13a0nwu6p.fsf@fess.ebiederm.org>
	<4B8843FE.4000404@cs.columbia.edu> <m1zl2vtzg4.fsf@fess.ebiederm.org>
	<4B885093.4070807@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pavel Emelyanov <xemul@parallels.com>,
	Ben Greear <greearb@candelatech.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	containers@lists.linux-foundation.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Daniel Lezcano <dlezcano@fr.ibm.com>
To: Oren Laadan <orenl@cs.columbia.edu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4B885093.4070807@cs.columbia.edu> (Oren Laadan's message of "Fri\, 26 Feb 2010 17\:52\:03 -0500")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Oren Laadan <orenl@cs.columbia.edu> writes:

> Can't think of a specific scenario, but I wonder if there would
> be a problem (security or otherwise) with a process that only
> partly belongs to a container, even if for a short time ?

If we can find an instance of that then there are fundamental problems
with setns.

The driving use case right now is for things like network namespaces where
userspace really wants to have several at once, and wants to be able to
control them all.

Eric

