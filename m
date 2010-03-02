From: Cedric Le Goater <legoater@free.fr>
Subject: Re: [RFC][PATCH] ns: Syscalls for better namespace sharing control.
Date: Tue, 02 Mar 2010 14:10:06 +0100
Message-ID: <4B8D0E2E.6020205@free.fr>
References: <4B4F24AC.70105@trash.net> <m1wry46es9.fsf@fess.ebiederm.org>	<1266931623.3973.643.camel@bigi> <m1iq9ocafv.fsf@fess.ebiederm.org>	<1266934817.3973.654.camel@bigi> <m1r5obbu2w.fsf@fess.ebiederm.org>	<1266966581.3973.675.camel@bigi> <m1pr3t2fvl.fsf_-_@fess.ebiederm.org>	<4B883987.6090408@parallels.com> <m1bpfbwuze.fsf@fess.ebiederm.org>	<4B883E6F.1060907@parallels.com> <m13a0nwu6p.fsf@fess.ebiederm.org>	<4B88D80A.8010701@parallels.com> <m1mxyvrqvk.fsf@fess.ebiederm.org>	<4B88E431.6040609@parallels.com> <m1bpfbqajn.fsf@fess.ebiederm.org>	<4B894564.7080104@parallels.com> <m1iq9io5sc.fsf@fess.ebiederm.org>	<4B89727C.9040602@parallels.com> <m1ljeempk6.fsf@fess.ebiederm.org>	<4B8AE8C1.1030305@free.fr> <m1ljebwwgd.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Lezcano <daniel.lezcano@free.fr>,
	Pavel Emelyanov <xemul@parallels.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	containers@lists.linux-foundation.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Ben Greear <greearb@candelatech.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <m1ljebwwgd.fsf@fess.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/01/2010 10:42 PM, Eric W. Biederman wrote:
> I am of two mind about my patches.  Right now they are a brilliant
> proof of concept that we can name namespaces without needing a
> namespace for the names of namespaces, and start to be a practical
> solution to the join problem.   At the same time, I'm not certain
> I like a solution that requires yet more syscalls so I ask myself
> is there not yet a simpler way.

thinking aloud,

what if you made the nsproxy a vfs_inode ? we could then mount the nsfs
to do all sorts of fs operations on the object, like notifying easily
its deletion. we would need to find a meaningful name, probably the inode
number.

one syscall (nsfd) would be required to get the nsproxy of a task (pid).
you can't guess that from an inode number.


C.
