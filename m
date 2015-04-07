From: yjin <yanjiang.jin@windriver.com>
Subject: Re: [PATCH] ethernet: e1000e: define lat_ns as u64 instead of s64
Date: Tue, 7 Apr 2015 10:35:05 +0800
Message-ID: <55234259.7030306@windriver.com>
References: <1428052673-16412-1-git-send-email-yanjiang.jin@windriver.com> <1428054159.2662.82.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <bruce.w.allan@intel.com>, <john.ronciak@intel.com>,
	<netdev@vger.kernel.org>, <jinyanjiang@gmail.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:45582 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752884AbbDGCe7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2015 22:34:59 -0400
In-Reply-To: <1428054159.2662.82.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jeff,

Thanks for your reminder. I used linux/scripts/get_maintainer.pl to get=
=20
the maintainer list before, next time I will do as you said.

Regards!
Yanjiang

On 2015=E5=B9=B404=E6=9C=8803=E6=97=A5 17:42, Jeff Kirsher wrote:
> On Fri, 2015-04-03 at 17:17 +0800, yanjiang.jin@windriver.com wrote:
>> From: Yanjiang Jin <yanjiang.jin@windriver.com>
>>
>> do_div() expects the type of "n" to be uint64_t, define "lat_ns" as
>> u64 to
>> avoid the below warning, also update its correlative operations and
>> data.
>>
>> In file included from ./arch/powerpc/include/asm/div64.h:1:0,
>>                   from include/linux/kernel.h:124,
>>                   from include/linux/list.h:8,
>>                   from include/linux/timer.h:4,
>>                   from drivers/net/ethernet/intel/e1000e/e1000.h:29,
>>                   from drivers/net/ethernet/intel/e1000e/ich8lan.c:5=
9:
>> drivers/net/ethernet/intel/e1000e/ich8lan.c: In function
>> 'e1000_platform_pm_pch_lpt':
>> include/asm-generic/div64.h:43:28: warning: comparison of distinct
>> pointer types lacks a cast [enabled by default]
>>    (void)(((typeof((n)) *)0) =3D=3D ((uint64_t *)0)); \
>>                              ^
>> drivers/net/ethernet/intel/e1000e/ich8lan.c:1016:4: note: in expansi=
on
>> of macro 'do_div'
>>      do_div(lat_ns, speed);
>>
>> Signed-off-by: Yanjiang Jin <yanjiang.jin@windriver.com>
>> ---
>>   drivers/net/ethernet/intel/e1000e/ich8lan.c | 8 ++++----
>>   1 file changed, 4 insertions(+), 4 deletions(-)
> Added intel-wired-lan mailing list (used for patches like this)
> Removed LKML ... (wrong mailing list to be mailing for patches like
> this)
> Removed e1000-devel ... (no longer used for kernel patches)
> Removed linux.nics ... (no longer used for kernel patches)
>
> Also removed Intel developers with no interest in e1000e patches ...
>
> Thanks Yanjiang, I will add your patch to my queue.
>
