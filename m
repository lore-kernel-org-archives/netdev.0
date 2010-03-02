From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [RFC][PATCH] ns: Syscalls for better namespace sharing
 control.
Date: Tue, 2 Mar 2010 16:14:23 +0100 (CET)
Message-ID: <alpine.LSU.2.01.1003021613570.17303@obet.zrqbmnf.qr>
References: <4B4F24AC.70105@trash.net> <m13a0tf17t.fsf@fess.ebiederm.org> <1266875729.3673.12.camel@bigi> <m1wry46es9.fsf@fess.ebiederm.org> <1266931623.3973.643.camel@bigi> <m1iq9ocafv.fsf@fess.ebiederm.org> <1266934817.3973.654.camel@bigi>
 <m1r5obbu2w.fsf@fess.ebiederm.org> <1266966581.3973.675.camel@bigi> <m1pr3t2fvl.fsf_-_@fess.ebiederm.org> <4B883987.6090408@parallels.com> <m1bpfbwuze.fsf@fess.ebiederm.org> <4B883E6F.1060907@parallels.com> <m13a0nwu6p.fsf@fess.ebiederm.org>
 <4B88D80A.8010701@parallels.com> <m1mxyvrqvk.fsf@fess.ebiederm.org> <4B88E431.6040609@parallels.com> <m1bpfbqajn.fsf@fess.ebiederm.org> <4B894564.7080104@parallels.com> <m1iq9io5sc.fsf@fess.ebiederm.org> <4B89727C.9040602@parallels.com> <m1ljeempk6.fsf@fess.ebiederm.org>
 <4B8AE8C1.1030305@free.fr> <4B8D28CF.8060304@parallels.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Daniel Lezcano <daniel.lezcano@free.fr>,
	"Eric W. Biederman" <ebiederm@xmission.com>, hadi@cyberus.ca,
	Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	containers@lists.linux-foundation.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Ben Greear <greearb@candelatech.com>,
	Serge Hallyn <serue@us.ibm.com>,
	Matt Helsley <matthltc@us.ibm.com>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4B8D28CF.8060304@parallels.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 2010-03-02 16:03, Pavel Emelyanov wrote:

>> I agree with all the points you and Pavel you talked about but I don't 
>> feel comfortable to have the current process to switch the pid namespace 
>> because of the process tree hierarchy (what will be the parent of the 
>> process when you enter the pid namespace for example).
>
>The answer is - the one, that used to be. I see no problems with it.
>Do you?

But perhaps it could be named "namespacefd" instead of nsfd, to reduce 
potential clashes (because glibc will usually just use the same name 
when making the syscall available as a C function).
