From: "Vegard Nossum" <vegard.nossum@gmail.com>
Subject: Re: [bug, netconsole, SLUB] BUG skbuff_head_cache: Poison overwritten
Date: Mon, 21 Jul 2008 13:41:54 +0200
Message-ID: <19f34abd0807210441o75c07e0fs60b49157318f59bb@mail.gmail.com>
References: <20080717214222.GA29449@elte.hu>
	 <19f34abd0807171627t1dd0ac5bx26535b5e19606835@mail.gmail.com>
	 <20080717235657.GB6833@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Pekka Enberg" <penberg@cs.helsinki.fi>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: "Ingo Molnar" <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.173]:34724 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755657AbYGULl4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 07:41:56 -0400
Received: by wf-out-1314.google.com with SMTP id 27so1549863wfd.4
        for <netdev@vger.kernel.org>; Mon, 21 Jul 2008 04:41:54 -0700 (PDT)
In-Reply-To: <20080717235657.GB6833@elte.hu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 18, 2008 at 1:56 AM, Ingo Molnar <mingo@elte.hu> wrote:
>
> * Vegard Nossum <vegard.nossum@gmail.com> wrote:
>
>> On Thu, Jul 17, 2008 at 11:42 PM, Ingo Molnar <mingo@elte.hu> wrote:
>> > With this config:
>> >
>> >   http://redhat.com/~mingo/misc/config-Thu_Jul_17_20_24_45_CEST_2008.bad
>> >
>>
>> It doesn't actually work. The config says
>>
>>     # head: 088fcf34
>>
>> and I checked out this from the tip tree. But kernel-config still
>> complains about unknown config options... What went wrong?
>
> that's ok - i've got some local qa helpers that have config options.
>
> Things like making SMP bootups more likely in randconfig, adding various
> boot parameters to the bootup via .config methods (so that boot
> parameters can be randomized via make randconfig), etc.

Hm, your config doesn't contain SLUB_DEBUG either. Isn't that a
requirement for seeing the BUG you're getting?

$ grep SLUB config-Thu_Jul_17_20_24_45_CEST_2008.bad
# CONFIG_SLUB_DEBUG is not set
CONFIG_SLUB=y

Did you post the wrong config?


Vegard

-- 
"The animistic metaphor of the bug that maliciously sneaked in while
the programmer was not looking is intellectually dishonest as it
disguises that the error is the programmer's own creation."
	-- E. W. Dijkstra, EWD1036
