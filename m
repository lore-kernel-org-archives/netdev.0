From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [RFC][PATCH] ns: Syscalls for better namespace sharing control.
Date: Mon, 8 Mar 2010 15:49:45 -0600
Message-ID: <20100308214945.GA26617@us.ibm.com>
References: <4B92C886.9020507@free.fr>
 <m1fx4bxlfy.fsf@fess.ebiederm.org>
 <4B952BBE.6070507@free.fr>
 <m11vfuvi1t.fsf@fess.ebiederm.org>
 <4B9556A9.60206@free.fr>
 <m11vfusgsa.fsf@fess.ebiederm.org>
 <4B95611C.5060403@free.fr>
 <m1sk8ar15b.fsf@fess.ebiederm.org>
 <4B956852.7050804@free.fr>
 <m1lje2qzf4.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Lezcano <daniel.lezcano@free.fr>,
	Pavel Emelyanov <xemul@parallels.com>,
	Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	containers@lists.linux-foundation.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Ben Greear <greearb@candelatech.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m1lje2qzf4.fsf@fess.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Eric W. Biederman (ebiederm@xmission.com):
> Daniel Lezcano <daniel.lezcano@free.fr> writes:
> I guess my meaning is I was expecting.
> child = fork();
> if (child == 0) {
> 	execve(...);
> }
> waitpid(child);
> 
> This puts /bin/sh in the container as well.
> 
> I'm not certain about the /proc/self thing I have never encountered that.
> But I guess if your pid is outside of the pid namespace of that instance
> of proc /proc/self will be a broken symlink.
> 
> Eric

Hmm, worse than a broken symlink, will it be a wrong symlink if just
the right pid is created in the container?

-serge
