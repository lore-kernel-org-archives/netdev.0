From: Peter Moody <pmoody@google.com>
Subject: Re: [PATCH v2 0/2] RFC, aiding pid/network correlation
Date: Sun, 03 Aug 2014 14:57:35 -0700
Message-ID: <r3nd2chjkxc.fsf@perdido.sfo.corp.google.com>
References: <1406856100-21674-1-git-send-email-pmoody@google.com>
	<87y4v876bs.fsf@synack.fr> <r3noaw4m8g6.fsf@perdido.sfo.corp.google.com>
	<lrhr02$ncj$1@ger.gmane.org> <r3nzjfmjr07.fsf@perdido.sfo.corp.google.com>
	<lrk4f5$4vo$2@ger.gmane.org> <r3nvbqajovk.fsf@perdido.sfo.corp.google.com>
	<lrk6or$unu$2@ger.gmane.org> <r3nr40yjo1e.fsf@perdido.sfo.corp.google.com>
	<lrk7gb$unu$4@ger.gmane.org> <lrk7s8$88k$2@ger.gmane.org>
	<r3nk36qjmc9.fsf@perdido.sfo.corp.google.com> <lrkb1l$4oh$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-security-module@vger.kernel.org, netdev@vger.kernel.org
To: Alex Elsayed <eternaleye@gmail.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <lrkb1l$4oh$1@ger.gmane.org> (Alex Elsayed's message of "Sat\, 02
	Aug 2014 20\:41\:38 -0700")
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Sat, Aug 02 2014 at 20:41, Alex Elsayed wrote:
> Peter Moody wrote:
>
>> 
>> On Sat, Aug 02 2014 at 19:47, Alex Elsayed wrote:
>>>> #2012/04/08 05:03:03# global-pid=3720 result=allowed priority=100 / read
>>>> path="/tmp/file1" task.pid=3720 task.ppid=3653 task.uid=0 task.gid=0
>>>> task.euid=0 task.egid=0 task.suid=0 task.sgid=0 task.fsuid=0
>>>> task.fsgid=0 task.type!=execute_handler task.exe="/bin/cat"
>>>> task.domain="/usr/sbin/sshd" path.uid=0 path.gid=0 path.ino=2113451
>>>> path.major=8 path.minor=1 path.perm=0644 path.type=file
>>>> path.fsmagic=0xEF53 path.parent.uid=0 path.parent.gid=0
>>>> path.parent.ino=2097153 path.parent.major=8 path.parent.minor=1
>>>> path.parent.perm=01777 path.parent.type=directory
>>>> path.parent.fsmagic=0xEF53
>>>
>>> Actually, now that I look at that, you'd need to audit 'domain
>>> transition' events too - since that contains all the relevant PIDs, then
>>> the most recent domain transition with all of the right PIDs is
>>> sufficient to rebuild the tree back to init (recursively)
>> 
>> How are network events logged? The documentation on caitsith.sourceforge
>> is lacking.
>
> It depends on the event - if you look at the per-event docs[1], you'll see 
> the variables it'll log. For instance, inet_stream_bind has 'ip', 'port', 
> and 'task.$attribute' listed (and hyperlinked), so it'll log like this:

Is this all caitsaith-specific? I don't see how to test what you're
describing with tomoyo.

 Cheers,
 peter
