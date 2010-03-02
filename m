From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC][PATCH] ns: Syscalls for better namespace sharing control.
Date: Tue, 02 Mar 2010 13:45:16 -0800
Message-ID: <m1aauqv1n7.fsf@fess.ebiederm.org>
References: <4B4F24AC.70105@trash.net> <m1iq9ocafv.fsf@fess.ebiederm.org>
	<1266934817.3973.654.camel@bigi> <m1r5obbu2w.fsf@fess.ebiederm.org>
	<1266966581.3973.675.camel@bigi> <m1pr3t2fvl.fsf_-_@fess.ebiederm.org>
	<4B883987.6090408@parallels.com> <m1bpfbwuze.fsf@fess.ebiederm.org>
	<4B883E6F.1060907@parallels.com> <m13a0nwu6p.fsf@fess.ebiederm.org>
	<4B88D80A.8010701@parallels.com> <m1mxyvrqvk.fsf@fess.ebiederm.org>
	<4B88E431.6040609@parallels.com> <m1bpfbqajn.fsf@fess.ebiederm.org>
	<4B894564.7080104@parallels.com> <m1iq9io5sc.fsf@fess.ebiederm.org>
	<4B89727C.9040602@parallels.com> <m1ljeempk6.fsf@fess.ebiederm.org>
	<4B8AE8C1.1030305@free.fr> <4B8D28CF.8060304@parallels.com>
	<alpine.LSU.2.01.1003021613570.17303@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pavel Emelyanov <xemul@parallels.com>,
	Daniel Lezcano <daniel.lezcano@free.fr>, hadi@cyberus.ca,
	Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	containers@lists.linux-foundation.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Ben Greear <greearb@candelatech.com>,
	Serge Hallyn <serue@us.ibm.com>,
	Matt Helsley <matthltc@us.ibm.com>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.01.1003021613570.17303@obet.zrqbmnf.qr> (Jan Engelhardt's message of "Tue\, 2 Mar 2010 16\:14\:23 +0100 \(CET\)")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jan Engelhardt <jengelh@medozas.de> writes:

> On Tuesday 2010-03-02 16:03, Pavel Emelyanov wrote:
>
>>> I agree with all the points you and Pavel you talked about but I don't 
>>> feel comfortable to have the current process to switch the pid namespace 
>>> because of the process tree hierarchy (what will be the parent of the 
>>> process when you enter the pid namespace for example).
>>
>>The answer is - the one, that used to be. I see no problems with it.
>>Do you?
>
> But perhaps it could be named "namespacefd" instead of nsfd, to reduce 
> potential clashes (because glibc will usually just use the same name 
> when making the syscall available as a C function).

Maybe.  namespacefd seems like a real mouthful.  I agree nsfd might be
a bit non-obvious for a rarish syscall.

Eric

