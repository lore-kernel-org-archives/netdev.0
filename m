From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [E1000-devel] networking probs in next-20081203
Date: Thu, 04 Dec 2008 23:49:14 -0800
Message-ID: <m1k5afqcxx.fsf@frodo.ebiederm.org>
References: <49381644.8020502@intel.com>
	<20081204175236.GA19808@x200.localdomain>
	<1228414280.11091.54.camel@moss-spartans.epoch.ncsc.mil>
	<20081204.102138.123959105.davem@davemloft.net>
	<1228419142.11091.90.camel@moss-spartans.epoch.ncsc.mil>
	<1228421219.11091.94.camel@moss-spartans.epoch.ncsc.mil>
	<m1bpvrslk0.fsf@frodo.ebiederm.org>
	<alpine.LRH.1.10.0812051243190.11818@tundra.namei.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Smalley <sds@tycho.nsa.gov>,
	David Miller <davem@davemloft.net>, adobriyan@gmail.com,
	auke-jan.h.kok@intel.com, akpm@linux-foundation.org,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	eparis@parisplace.org
To: James Morris <jmorris@namei.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:48815 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750805AbYLEH41 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2008 02:56:27 -0500
In-Reply-To: <alpine.LRH.1.10.0812051243190.11818@tundra.namei.org> (James
	Morris's message of "Fri, 5 Dec 2008 13:03:08 +1100 (EST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

James Morris <jmorris@namei.org> writes:

> On Thu, 4 Dec 2008, Eric W. Biederman wrote:
>
>> Which piece of selinux magic did I miss?
>
> The problem is that SELinux doesn't know anything about the new filesystem 
> type, and specifically, to treat it like procfs.  There are a couple 
> workarounds we can try to prevent this specific problem from cropping up 
> again.

The thing is I believe I changed the internal filesystem test to
strncmp(fstype, "proc", 4);

Which should match both proc and proc/net

And likewise I thought I provided the same name by for the magic label
lookup by name.

>> In particular can you tell if this was a code bug or a logic bug?
>
> I wouldn't say it was a bug, more a consequence of necessarily imperfect 
> encapsulation of the security code via LSM.  It's just something we have to 
> keep an eye out for.

Yes.  Was the piece I missed in the LSM rules loaded from user space?

Eric
