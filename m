From: Gerhard Wiesinger <lists@wiesinger.com>
Subject: Re: Linux 4.2.4
Date: Mon, 9 Nov 2015 13:35:11 +0100
Message-ID: <564092FF.2070100@wiesinger.com>
References: <20151023003306.GA25388@kroah.com>
 <562C83FD.6010402@wiesinger.com> <20151025082547.GA22300@kroah.com>
 <20151025090308.GA17656@1wt.eu> <562CA13C.90500@wiesinger.com>
 <20151025094634.GA6832@1wt.eu> <562CB396.2080509@wiesinger.com>
 <20151025162955.GA8375@kroah.com> <563F5345.7060001@wiesinger.com>
 <20151108172022.GC29613@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Willy Tarreau <w@1wt.eu>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org, stable@vger.kernel.org, lwn@lwn.net,
	Jiri Slaby <jslaby@suse.cz>
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps01.wiesinger.com ([46.36.37.179]:37556 "EHLO
	vps01.wiesinger.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751352AbbKIMfW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2015 07:35:22 -0500
In-Reply-To: <20151108172022.GC29613@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08.11.2015 18:20, Greg KH wrote:
> On Sun, Nov 08, 2015 at 02:51:01PM +0100, Gerhard Wiesinger wrote:
>> On 25.10.2015 17:29, Greg KH wrote:
>>> On Sun, Oct 25, 2015 at 11:48:54AM +0100, Gerhard Wiesinger wrote:
>>>> On 25.10.2015 10:46, Willy Tarreau wrote:
>>>>> ipset *triggered* the problem. The whole stack dump would tell more.
>>>> OK, find the stack traces in the bug report:
>>>> https://bugzilla.redhat.com/show_bug.cgi?id=1272645
>>>>
>>>> Kernel 4.1.10 triggered also a kernel dump when playing with ipset commands
>>>> and IPv6, details in the bug report  ....
>>>>
>>>>>> Kernel 4.2 seems to me not well tested in the netfilter parts at all
>>>>>> (Bug with already known bugfix
>>>>>> https://lists.debian.org/debian-kernel/2015/10/msg00034.html was
>>>>>> triggered on 2 of 3 of my machines, the new bug on 1 of 1 tested machine).
>>>>> There's a reason why Greg maintains stable and LTS kernels :-)
>>>> Stable kernels don't crash but definiton. :-)
>>>>
>>>> At least triggered 2 kernel panics in 5min, even with 4.1.10 and ipset
>>>> commands ...
>>> Does this happen also with Linus's tree?  I suggest you ask the
>>> networking developers about this on netdev@vger.kernel.org, there's
>>> nothing that I can do on my own about this, sorry.
>> Patch is now available, see:
>> [PATCH 0/3] ipset patches for nf
>> https://marc.info/?l=netfilter-devel&m=144690007708041&w=2
>> https://marc.info/?l=netfilter-devel&m=144690007808042&w=2
>> https://marc.info/?l=netfilter-devel&m=144690008608043&w=2
>> https://marc.info/?l=netfilter-devel&m=144690007708039&w=2
>> [ANNOUNCE] ipset 6.27 released
>> https://marc.info/?l=netfilter-devel&m=144690048308099&w=2
>>
>> Requires also new userland ipset version.
>>
>> Please integrate it upstream.
>>
>> Thanx to Jozsef Kadlecsik for fixing it.
> That's great, can you let me know the git commits that end up in Linus's
> tree?  That's what we need for the stable kernel.

Find the commits here:
https://git.kernel.org/cgit/linux/kernel/git/pablo/nf.git/
https://git.kernel.org/cgit/linux/kernel/git/pablo/nf.git/commit/?id=e75cb467df29a428612c162e6f1451c5c0717091

Don't know exactly the merging processes, so feel free to merge or 
contact Pablo.

Ciao,
Gerhard
