From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC][PATCH] ns: Syscalls for better namespace sharing control.
Date: Thu, 25 Feb 2010 14:31:11 -0800
Message-ID: <m1mxyxymkw.fsf@fess.ebiederm.org>
References: <4B4F24AC.70105@trash.net> <1263481549.23480.24.camel@bigi>
	<4B4F3A50.1050400@trash.net> <1263490403.23480.109.camel@bigi>
	<4B50403A.6010507@trash.net> <1263568754.23480.142.camel@bigi>
	<m13a0tf17t.fsf@fess.ebiederm.org> <1266875729.3673.12.camel@bigi>
	<m1wry46es9.fsf@fess.ebiederm.org> <1266931623.3973.643.camel@bigi>
	<m1iq9ocafv.fsf@fess.ebiederm.org> <1266934817.3973.654.camel@bigi>
	<m1r5obbu2w.fsf@fess.ebiederm.org> <1266966581.3973.675.camel@bigi>
	<m1pr3t2fvl.fsf_-_@fess.ebiederm.org> <4B86EC45.3060005@free.fr>
	<m1mxyx0yv7.fsf@fess.ebiederm.org> <4B86F5EC.60902@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, Linux Netdev List <netdev@vger.kernel.org>,
	containers@lists.linux-foundation.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Ben Greear <greearb@candelatech.com>,
	Daniel Lezcano <dlezcano@fr.ibm.com>
To: Daniel Lezcano <daniel.lezcano@free.fr>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4B86F5EC.60902@free.fr> (Daniel Lezcano's message of "Thu\, 25 Feb 2010 23\:13\:00 +0100")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Daniel Lezcano <daniel.lezcano@free.fr> writes:

>> No, the plan is only one namespace at a time.
>>
>> It would not be much of a change to support multiple namespaces,
>> but I don't think I want to go there.  Bitmaps filling up are
>> ugly and I don't see what would be gained.
>>   
> The idea I had in mind when I asked this question was if we can "move" a process
> inside a container, aka a set of namespaces :)

Yes.

>> I does make sense to support all of the namespaces we can support
>> with unshare, but with nstype as an enumeration not as a bitmap.
>>   
> I suppose when you say "to support all of the namespaces we can support with
> *unshare*", you exclude the pid namespace which is created only with clone,
> right ? Do you think we can extend the concept to all the namespaces including
> the pid_namespace ?

Yes, and I think also the credential/uid namespace.

It is possible that this could be the basis for a general purpose
enter, but that is not the primary motivation.  I am after the
easy cases simple cases.  So I can modify /sbin/ip to take advantage
of it.

Eric

