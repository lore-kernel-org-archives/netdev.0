From: Chris Metcalf <cmetcalf@tilera.com>
Subject: Re: [PATCH v3] tilegx network driver: initial support
Date: Thu, 3 May 2012 11:45:32 -0400
Message-ID: <4FA2A81C.8020402@tilera.com>
References: <201204291859.q3TIxIWB007275@farm-0027.internal.tilera.com> <201204301435.08810.arnd@arndb.de> <201205011759.q41HxR21020043@farm-0012.internal.tilera.com> <20120503.014156.149171097979026872.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <arnd@arndb.de>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usmamail.tilera.com ([12.216.194.151]:24192 "EHLO
	USMAMAIL.TILERA.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755492Ab2ECPpe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2012 11:45:34 -0400
In-Reply-To: <20120503.014156.149171097979026872.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/3/2012 1:41 AM, David Miller wrote:
> From: Chris Metcalf <cmetcalf@tilera.com>
> Date: Mon, 17 Sep 2001 00:00:00 -0400
>
>> +/* #define USE_SIM_PRINTF */
>> +
>> +#ifdef USE_SIM_PRINTF
>> +
>> +static __attribute__((unused, format (printf, 1, 2))) void
>> +sim_printf(const char *format, ...)
>  ...
>> +/* HACK: Allow use of "sim_printf()" instead of "printk()". */
>> +#define printk sim_printf
>> +
>> +#endif
> This doesn't belong in a driver.
>
> You want a debugging console driver that uses that special SIM output
> facility instead.
>
> Therefore, please remove this sim_printf stuff completely.

Thanks, I've removed it from my branch.  (Since it's a trivial update, I
won't repost the change on LKML unless I get any more feedback that needs
addressing.)

I've checked in support for a "sim_console" boot flag that modifies the
behavior of the tile-specific console driver to use the simulator output
facility instead.  I'll plan to push that to LKML with the next batch of
changes I post.

-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com
