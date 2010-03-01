From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC][PATCH] ns: Syscalls for better namespace sharing control.
Date: Mon, 01 Mar 2010 13:42:10 -0800
Message-ID: <m1ljebwwgd.fsf@fess.ebiederm.org>
References: <4B4F24AC.70105@trash.net> <m1wry46es9.fsf@fess.ebiederm.org>
	<1266931623.3973.643.camel@bigi> <m1iq9ocafv.fsf@fess.ebiederm.org>
	<1266934817.3973.654.camel@bigi> <m1r5obbu2w.fsf@fess.ebiederm.org>
	<1266966581.3973.675.camel@bigi> <m1pr3t2fvl.fsf_-_@fess.ebiederm.org>
	<4B883987.6090408@parallels.com> <m1bpfbwuze.fsf@fess.ebiederm.org>
	<4B883E6F.1060907@parallels.com> <m13a0nwu6p.fsf@fess.ebiederm.org>
	<4B88D80A.8010701@parallels.com> <m1mxyvrqvk.fsf@fess.ebiederm.org>
	<4B88E431.6040609@parallels.com> <m1bpfbqajn.fsf@fess.ebiederm.org>
	<4B894564.7080104@parallels.com> <m1iq9io5sc.fsf@fess.ebiederm.org>
	<4B89727C.9040602@parallels.com> <m1ljeempk6.fsf@fess.ebiederm.org>
	<4B8AE8C1.1030305@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pavel Emelyanov <xemul@parallels.com>, hadi@cyberus.ca,
	Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	containers@lists.linux-foundation.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Ben Greear <greearb@candelatech.com>,
	Serge Hallyn <serue@us.ibm.com>,
	Matt Helsley <matthltc@us.ibm.com>
To: Daniel Lezcano <daniel.lezcano@free.fr>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4B8AE8C1.1030305@free.fr> (Daniel Lezcano's message of "Sun\, 28 Feb 2010 23\:05\:53 +0100")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Daniel Lezcano <daniel.lezcano@free.fr> writes:

> I agree with all the points you and Pavel you talked about but I don't feel
> comfortable to have the current process to switch the pid namespace because of
> the process tree hierarchy (what will be the parent of the process when you
> enter the pid namespace for example). What is the difference with the sys_bindns
> or the sys_hijack, proposed a couple of years ago ?

I think what has changed is:
- We have mostly completed most of the namespace work.
- We have operational experience with the current namespaces.
- We have people not in the core containers group feeling the pain
  of not having some of these features.

So I think we are at point where we can perhaps talk about these
things and finally solve some of these issues.

Clearly how to enter a container is on your and Pavel's mind as big
concerns.  I am aiming a little lower.

I am of two mind about my patches.  Right now they are a brilliant
proof of concept that we can name namespaces without needing a
namespace for the names of namespaces, and start to be a practical
solution to the join problem.   At the same time, I'm not certain
I like a solution that requires yet more syscalls so I ask myself
is there not yet a simpler way.

Hopefully we can resolve something before the next merge window.

Eric
