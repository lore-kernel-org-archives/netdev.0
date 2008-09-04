From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: linux-next: Tree for September 3
Date: Thu, 04 Sep 2008 13:31:01 -0700
Message-ID: <m163pb4pru.fsf@frodo.ebiederm.org>
References: <20080903191619.6b6b230e.sfr@canb.auug.org.au>
	<20080903214634.ea17ff53.akpm@linux-foundation.org>
	<alpine.LFD.1.10.0809032201510.3378@nehalem.linux-foundation.org>
	<20080903223318.84b6ce8b.akpm@linux-foundation.org>
	<alpine.LFD.1.10.0809040045190.3378@nehalem.linux-foundation.org>
	<20080904012544.cabed847.akpm@linux-foundation.org>
	<alpine.LFD.1.10.0809040143350.3452@nehalem.linux-foundation.org>
	<20080904015701.5959623a.akpm@linux-foundation.org>
	<alpine.LFD.1.10.0809040203510.3452@nehalem.linux-foundation.org>
	<20080904104554.32ffebea.akpm@linux-foundation.org>
	<alpine.LFD.1.10.0809041058140.3400@nehalem.linux-foundation.org>
	<20080904113408.d47c65f6.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Yinghai Lu <yhlu.kernel@gmail.com>,
	Ivan Kokshaysky <ink@jurassic.park.msu.ru>,
	Jesse Barnes <jbarnes@virtuousgeek.org>,
	netdev@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
	David Woodhouse <dwmw2@infradead.org>,
	Sam Ravnborg <sam@ravnborg.org>,
	john stultz <johnstul@us.ibm.com>,
	Thomas Gleixner <tglx@linutronix.de>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20080904113408.d47c65f6.akpm@linux-foundation.org> (Andrew
	Morton's message of "Thu, 4 Sep 2008 11:34:08 -0700")
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton <akpm@linux-foundation.org> writes:

> On Thu, 4 Sep 2008 11:05:21 -0700 (PDT) Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
>
>> > This is a pull of your tree from yesterday, ending at commit 
>> > fbb16e243887332dd5754e48ffe5b963378f3cd2
>> 
>> There's been various suggested patches by Al/Eric (added to cc) for 
>> /proc/net handling, but none of them have actually even been merged yet. 
>> So I don't think this code has changed in a while. 
>> 
>> Al, Eric, ideas?

There aren't any issues I know of with normal configurations
and the current proc code.

> I don't think I saw it on any other test machines.
>
> This machine runs SELinux.  Distro is FC5.

>> > config: http://userweb.kernel.org/~akpm/config-sony.txt
>> > dmesg: http://userweb.kernel.org/~akpm/dmesg-sony-without.txt
>> 
>> That whole thing should just be a simple symlink:
>> 
>> 	fs/proc/proc_net.c:     proc_symlink("net", NULL, "self/net");
>
> /proc/self/net looks fine.
>
>> are you sure it's a plain tree of mine, without any of the patches 
>> floating around between Eric/Al?
>
> yup, it's yesterday's mainline.

Does the problem happen if you disable selinux?

This feels like a case of selinux being over zealous.

Eric
