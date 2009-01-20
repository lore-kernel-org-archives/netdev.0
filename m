From: Samir Bellabes <sam@synack.fr>
Subject: Re: RFC: Mandatory Access Control for sockets aka "personal firewalls"
Date: Tue, 20 Jan 2009 22:42:45 +0100
Message-ID: <m2ljt53b8q.fsf@ssh.synack.fr>
References: <1232473719.24943.102.camel@sp-laptop3.sp-local>
	<m2prih3f9i.fsf@ssh.synack.fr>
	<alpine.LSU.2.00.0901202120240.24253@fbirervta.pbzchgretzou.qr>
	<200901201553.57022.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jan Engelhardt <jengelh@medozas.de>,
	Stephan Peijnik <stephan@peijnik.at>,
	"linux-security-module" <linux-security-module@vger.kernel.org>,
	netdev@vger.kernel.org,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>
To: Paul Moore <paul.moore@hp.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <200901201553.57022.paul.moore@hp.com> (Paul Moore's message of
	"Tue, 20 Jan 2009 15:53:56 -0500")
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Paul Moore <paul.moore@hp.com> writes:

> However, in dealing with the issue of personal firewalls I think the 
> biggest issue will be the user interaction as you described ... how do 
> you explain to a user who clicked the "allow" button that the system 
> rejected their traffic?

maybe because the personnal firewall is the only one which deal with the
LSM hook related to network (?)

>> >But what you are asking is to have multiple security models at the
>> > same time, with some kind of priority.
>> >I don't know if it's ok or not, but what I'm sure is that snet will
>> > use LSM hooks or your new framework without any problems in fact,
>> > as you are going to make some kind of wrapper on the members of the
>> > struct security_operations.
>>
>> jan>>> My opinion up to here would be to split LSM into the LSM
>> category
>>
>> >>> {selinux, apparmor, tomoyo} and the other, new LSM category
>> >>> {networking stuff}, just as a potential idea to get over the
>> >>> stacking / single LSM use  issue.
>> >
>> >Indeed I thought about that when writing snet.
>>
>> For starters, the existing LSM interface and the LSM  modules
>> themselves could be split up so as to provide
>>
>>  selinux.ko
>>   \_ selinux_net.ko
>>   \_ selinux_fs.ko
>>   ...
>>
>> just a suggestion to ease the thinking process for now.
>> If a purely network-related LSM does not have to think about
>> "do I need to implement FS hooks that do chaining or not..."
>> it is a lot better off.
>
> Unfortunately I don't think this solves the problem, it just changes it 
> slightly.  It is no longer "How do I enable SELinux and XXX personal 
> firewall?" but instead "How do I enable SELinux's network access 
> controls and XXX personal firewall?"

And introduce another one : "how do I make SElinux's network access
controls and Apparmor filesystem access controls working together ?"
this is the true deal in this kind of solution.

sam
