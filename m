From: Rami Rosen <roszenrami@gmail.com>
Subject: Re: linux-next: Tree for Jan 4 (net/bridge)
Date: Fri, 4 Jan 2013 21:54:52 +0200
Message-ID: <CAKoUArn=6UMjcKC6rnUmpkXFxQvSWnc=1N44iZFPKn80aMBNvA@mail.gmail.com>
References: <20130104152814.3a3cf74bdec76cea09d3e134@canb.auug.org.au>
	<50E72977.7030605@infradead.org>
	<20130104112716.596f9085@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Randy Dunlap <rdunlap@infradead.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	bridge@lists.linux-foundation.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f169.google.com ([209.85.216.169]:52573 "EHLO
	mail-qc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755075Ab3ADTyy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2013 14:54:54 -0500
In-Reply-To: <20130104112716.596f9085@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

The cause of the problem in net tree (but **not** net-next tree) is:
commit 3ec8e9f085bcaef0de1077f555c2c5102c223390
"bridge: Correctly unregister MDB rtnetlink handlers"
and it is fixed by a patch from me, for the net tree, from yesterday.

see:
http://www.spinics.net/lists/netdev/msg221168.html

probably this patch, which was applied to net,  was not pulled yet.

I believe that since the commit above was not to net-next, this
problem is not observed in your tree.

Rami Rosen
http://ramirose.wix.com/ramirosen

On Fri, Jan 4, 2013 at 9:27 PM, Stephen Hemminger <shemminger@vyatta.com> wrote:
> On Fri, 04 Jan 2013 11:11:51 -0800
> Randy Dunlap <rdunlap@infradead.org> wrote:
>
>> On 01/03/13 20:28, Stephen Rothwell wrote:
>> > Hi all,
>> >
>> > Changes since 20130103:
>> >
>>
>> on i386 and x86_64:
>>
>>   CC      net/bridge/br_netlink.o
>> net/bridge/br_netlink.c: In function 'br_netlink_init':
>> net/bridge/br_netlink.c:307:2: error: implicit declaration of function 'br_mdb_init' [-Werror=implicit-function-declaration]
>> net/bridge/br_netlink.c:314:2: error: implicit declaration of function 'br_mdb_uninit' [-Werror=implicit-function-declaration]
>> cc1: some warnings being treated as errors
>> make[3]: *** [net/bridge/br_netlink.o] Error 1
>>
>>
>> Full randconfig file is attached.
>>
>>
>
> Problem not observed with current net-next and your configuration.
> Probably already fixed.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
