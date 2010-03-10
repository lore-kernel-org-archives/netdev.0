From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: [RFC][PATCH] ns: Syscalls for better namespace sharing control.
Date: Wed, 10 Mar 2010 22:16:05 +0100
Message-ID: <4B980C15.9000908@free.fr>
References: <4B88E431.6040609@parallels.com> <4B8D28CF.8060304@parallels.com>	<20100302211942.GA17816@us.ibm.com> <m1y6iaqsmm.fsf@fess.ebiederm.org>	<20100303000743.GA13744@us.ibm.com> <m1ocj6qljj.fsf@fess.ebiederm.org>	<4B8E9370.3050300@parallels.com> <m17hptjh3m.fsf@fess.ebiederm.org>	<4B9158F5.5040205@parallels.com> <m1vdda1pmx.fsf@fess.ebiederm.org>	<4B926B1B.5070207@free.fr> <m1aaulyy5c.fsf@fess.ebiederm.org>	<4B92C886.9020507@free.fr> <m1fx4bxlfy.fsf@fess.ebiederm.org>	<4B952BBE.6070507@free.fr> <m11vfuvi1t.fsf@fess.ebiederm.org>	<4B9556A9.60206@free.fr> <m11vfusgsa.fsf@fess.ebiederm.org>	<4B95611C.5060403@free.fr> <m1sk8ar15b.fsf@fess.ebiederm.org>	<4B956852.7050804@free.fr> <m1lje2qzf4.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pavel Emelyanov <xemul@parallels.com>,
	Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>,
	Serge Hallyn <serue@us.ibm.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	containers@lists.linux-foundation.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Ben Greear <greearb@candelatech.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <m1lje2qzf4.fsf@fess.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
> Daniel Lezcano <daniel.lezcano@free.fr> writes:
>   

[ ... ]

> I guess my meaning is I was expecting.
> child = fork();
> if (child == 0) {
> 	execve(...);
> }
> waitpid(child);
>
> This puts /bin/sh in the container as well.
>   

Eric,

at this point I did not fall in any obvious bug and I was able to enter 
/ execute commands directly inside the container.

Excellent !

Thanks
  -- Daniel


