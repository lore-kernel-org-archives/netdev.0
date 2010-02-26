From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC][PATCH] ns: Syscalls for better namespace sharing control.
Date: Thu, 25 Feb 2010 16:53:16 -0800
Message-ID: <m1bpfczukj.fsf@fess.ebiederm.org>
References: <1263568754.23480.142.camel@bigi>
	<m13a0tf17t.fsf@fess.ebiederm.org> <1266875729.3673.12.camel@bigi>
	<m1wry46es9.fsf@fess.ebiederm.org> <1266931623.3973.643.camel@bigi>
	<m1iq9ocafv.fsf@fess.ebiederm.org> <1266934817.3973.654.camel@bigi>
	<m1r5obbu2w.fsf@fess.ebiederm.org> <1266966581.3973.675.camel@bigi>
	<m1pr3t2fvl.fsf_-_@fess.ebiederm.org>
	<20100225214656.GS3604@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, Daniel Lezcano <dlezcano@fr.ibm.com>,
	Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	containers@lists.linux-foundation.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Ben Greear <greearb@candelatech.com>,
	Serge Hallyn <serue@us.ibm.com>
To: Matt Helsley <matthltc@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:50557 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759391Ab0BZAx0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2010 19:53:26 -0500
In-Reply-To: <20100225214656.GS3604@count0.beaverton.ibm.com> (Matt Helsley's message of "Thu\, 25 Feb 2010 13\:46\:56 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Matt Helsley <matthltc@us.ibm.com> writes:


> 	Seems like an ok concept to me. Did you try doing this with
> anon_inodes and bind mounting the /proc/<pid>/fd/N as above to keep
> them alive and name them?

Of course this part doesn't work in my patch because I have the wrong
mnt_ns on my mount MS_NOUSER on my superblock.

MS_NOUSER is easy to get past.  Getting a vfsmount in the proper mnt
namespace could be tricky.

Eric
