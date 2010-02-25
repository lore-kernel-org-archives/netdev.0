From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC][PATCH] ns: Syscalls for better namespace sharing control.
Date: Thu, 25 Feb 2010 13:54:29 -0800
Message-ID: <m1635l0yne.fsf@fess.ebiederm.org>
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
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100225214656.GS3604@count0.beaverton.ibm.com> (Matt Helsley's message of "Thu\, 25 Feb 2010 13\:46\:56 -0800")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Matt Helsley <matthltc@us.ibm.com> writes:

> 	Seems like an ok concept to me. Did you try doing this with
> anon_inodes and bind mounting the /proc/<pid>/fd/N as above to keep
> them alive and name them?

I used a normal file.  anon_nodes strictly speaking might work, but they
keep their state in the struct file not in the struct dentry.  So even
if the anon_inodes survived they would not be good for anything.  Otherwise
I would have just reused the anon_inodes.

Eric
