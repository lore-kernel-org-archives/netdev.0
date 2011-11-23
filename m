From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH net-next] Sweep away N/A fw_version dustbunnies from the
 .get_drvinfo routine of a number of drivers
Date: Tue, 22 Nov 2011 16:32:46 -0800
Message-ID: <4ECC3F2E.1000609@hp.com>
References: <20111121205405.A0FF1290041F@tardy> <20111122222235.GA24136@electric-eye.fr.zoreil.com> <4ECC23AB.5060808@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:12062 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752935Ab1KWAcs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2011 19:32:48 -0500
In-Reply-To: <4ECC23AB.5060808@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/22/2011 02:35 PM, Rick Jones wrote:
> On 11/22/2011 02:22 PM, Francois Romieu wrote:
>> Rick Jones<raj@tardy.cup.hp.com> :
>> [...]
>>> Per discussion with Ben Hutchings and David Miller, go through and
>>> remove assignments of "N/A" to fw_version in various drivers'
>>> .get_drvinfo routines. While there clean-up some use of bare
>>> constants and such.
>>
>> Any reason why drivers/net/ethernet/realtek/r8169.c is left in the
>> cold ?
>
> No specific reason. I might not have caught it with my find/grep, or it
> might not have been built in my build environment - after I cloned
> net-next, I brought the .config file from my 64-bit ubuntu virtual
> system to the BE (been bringing it along rather like sourdough starter),
> did a make oldconfig, took all the defaults, did a "make" and then only
> modified those files for which I found the "N/A" in the .c file and
> which had a corresponding .o - that way I "knew" that my changes would
> at least be compiled subsequently and so minimizing the chances of
> incurring davem's wrath by sending him non-compiling code :)

I've sent a follow-up patch under separate cover.

FWIW, there are a number of other drivers which don't seem to be enabled 
by the .config I'm using, so I've not done any clean-ups on those.  Is 
there an easy way to light them all up?

rick
