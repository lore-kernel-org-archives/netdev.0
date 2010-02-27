From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [RFC][PATCH] ns: Syscalls for better namespace sharing control.
Date: Sat, 27 Feb 2010 11:30:02 +0300
Message-ID: <4B88D80A.8010701@parallels.com>
References: <4B4F24AC.70105@trash.net> <1263481549.23480.24.camel@bigi>	<4B4F3A50.1050400@trash.net> <1263490403.23480.109.camel@bigi>	<4B50403A.6010507@trash.net> <1263568754.23480.142.camel@bigi>	<m13a0tf17t.fsf@fess.ebiederm.org> <1266875729.3673.12.camel@bigi>	<m1wry46es9.fsf@fess.ebiederm.org> <1266931623.3973.643.camel@bigi>	<m1iq9ocafv.fsf@fess.ebiederm.org> <1266934817.3973.654.camel@bigi>	<m1r5obbu2w.fsf@fess.ebiederm.org> <1266966581.3973.675.camel@bigi>	<m1pr3t2fvl.fsf_-_@fess.ebiederm.org> <4B883987.6090408@parallels.com>	<m1bpfbwuze.fsf@fess.ebiederm.org> <4B883E6F.1060907@parallels.com> <m13a0nwu6p.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, Daniel Lezcano <dlezcano@fr.ibm.com>,
	Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	containers@lists.linux-foundation.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Ben Greear <greearb@candelatech.com>,
	Serge Hallyn <serue@us.ibm.com>,
	Matt Helsley <matthltc@us.ibm.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <m13a0nwu6p.fsf@fess.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
> Pavel Emelyanov <xemul@parallels.com> writes:
> 
>>>> Yet another set of per-namespace IDs along with CLONE_NEWXXX ones?
>>>> I currently have a way to create all namespaces we have with one
>>>> syscall. Why don't we have an ability to enter them all with one syscall?
>>> The CLONE_NEWXXX series of bits has been an royal pain to work with,
>>> and it appears to be unnecessary complications for no gain.
>> That's the answer for the "Yet another set..." question.
>> How about the "Why don't we have..." one?
> 
> I am not certain which question you are asking:
> 
> Why don't we have an ability to enter all namespaces with one syscall
> invocation?

Exactly. Please add at least the NSTYPE_NSPROXY or whatever, that will
pin all namespaces of a given pid from the very beginning.

> Why don't we have a syscall that allows us to enter every namespace?

This one is done in the patch, no?

Although the approach is OK for me, there's one design issue, that came
up to my mind recently: can we use this fd to wail for a namespace to 
stop? I currently don't see this ability, but this is something I require
badly.

Thoughts?

> Eric
> 
> 

