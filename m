From: "Jesse Brandeburg" <jesse.brandeburg@gmail.com>
Subject: Re: [RFC PATCH 02/12] On Tue, 23 Sep 2008, David Miller wrote:
Date: Fri, 3 Oct 2008 16:30:04 -0700
Message-ID: <4807377b0810031630t54e4bb46y87fe7e34f3be60ac@mail.gmail.com>
References: <20080930030825.22950.18891.stgit@jbrandeb-bw.jf.intel.com>
	 <200810021523.45884.jbarnes@virtuousgeek.org>
	 <20081003.134634.240211201.davem@davemloft.net>
	 <200810031429.22598.jbarnes@virtuousgeek.org>
	 <alpine.LNX.1.10.0810032338140.26779@jikos.suse.cz>
	 <4807377b0810031628x43f79eferdbb9c9c264a5816e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Jesse Barnes" <jbarnes@virtuousgeek.org>,
	"David Miller" <davem@davemloft.net>, jesse.brandeburg@intel.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	kkeil@suse.de, agospoda@redhat.com, arjan@linux.intel.com,
	david.graham@intel.com, bruce.w.allan@intel.com,
	john.ronciak@intel.com, "Thomas Gleixner" <tglx@linutronix.de>,
	chris.jones@canonical.com, tim.gardner@canonical.com,
	airlied@gmail.com, "Olaf Kirch" <okir@suse.de>,
	"Linus Torvalds" <torvalds@linux-foundation.org>
To: "Jiri Kosina" <jkosina@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.237]:1396 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753397AbYJCXaE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2008 19:30:04 -0400
Received: by rv-out-0506.google.com with SMTP id k40so1909445rvb.1
        for <netdev@vger.kernel.org>; Fri, 03 Oct 2008 16:30:04 -0700 (PDT)
In-Reply-To: <4807377b0810031628x43f79eferdbb9c9c264a5816e@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 3, 2008 at 4:28 PM, Jesse Brandeburg
<jesse.brandeburg@gmail.com> wrote:
> On Fri, Oct 3, 2008 at 2:45 PM, Jiri Kosina <jkosina@suse.cz> wrote:
>> Karsten has been testing kernel with these three patches from the series
>> applied:
>>
>>        e1000e: reset swflag after resetting hardware
>>        e1000e: fix lockdep issues
>>        e1000e: debug contention on NVM SWFLAG
>>
>> This was done on a hardware which previously triggered the bug in just a
>> few test iterations in quite a reliable way. Now, with these patches
>> applied, the EEPROM corruption didn't happen after several tens of
>> iterations.
>>
>> Please note, that the patch that disables the writes to EEPROM on hardware
>> level was *not* involved in this testing.
>>
>> Therefore it currently seems that these three patches really address the
>> race condition issue that was present in the e1000e driver.
>
> Our experience is different.  We are also testing with the "protection
> patch" reverted.
>
> We see that the problem specifically comes and goes when
> removing/adding the use of set_memory_ro/set_memory_rw to the driver.
>
> I'm working to catch the bad element in the act with a hardware
> breakpoint or an ITP (we're trying both)
>
>> It is still not clear why the bug started triggering all of a sudden for
>> so many people though.
>
> we plan to keep on working on this until we understand what is going on.

I removed the bad addresses from the cc: list
