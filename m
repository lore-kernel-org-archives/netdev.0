From: Jiri Slaby <jirislaby@gmail.com>
Subject: Re: linux-next: manual merge of the limits tree with the net and
 fsnotify trees
Date: Sat, 05 Dec 2009 15:21:24 +0100
Message-ID: <4B1A6C64.4050408@gmail.com>
References: <20091204183011.e92d36cd.sfr@canb.auug.org.au>	<4B18C15A.8060901@gmail.com> <20091205150053.48384393.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
Cc: Jiri Slaby <jirislaby@gmail.com>, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, Eric Paris <eparis@redhat.com>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Neil Horman <nhorman@tuxdriver.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f213.google.com ([209.85.220.213]:55674 "EHLO
	mail-fx0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755275AbZLEOVX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Dec 2009 09:21:23 -0500
In-Reply-To: <20091205150053.48384393.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/05/2009 05:00 AM, Stephen Rothwell wrote:
> On Fri, 04 Dec 2009 08:59:22 +0100 Jiri Slaby <jirislaby@gmail.com> wrote:
>>
>> On 12/04/2009 08:30 AM, Stephen Rothwell wrote:
>>> diff --cc arch/x86/ia32/ia32entry.S
>>> index da89ae1,c61ced2..0000000
>>> --- a/arch/x86/ia32/ia32entry.S
>>> +++ b/arch/x86/ia32/ia32entry.S
>>> @@@ -841,7 -841,6 +841,9 @@@ ia32_sys_call_table
>>>   	.quad compat_sys_pwritev
>>>   	.quad compat_sys_rt_tgsigqueueinfo	/* 335 */
>>>   	.quad sys_perf_event_open
>>>  +	.quad compat_sys_recvmmsg
>>>  +	.quad sys_fanotify_init
>>>  +	.quad sys32_fanotify_mark
>>> + 	.quad compat_sys_getprlimit
>>
>> Thanks, but please go on with the by-five numbering in comments.
> 
> I am sure that will be done by whoever does the final conflict
> resolution.

Ah, sorry, I apparently don't know how this works. Thanks for explanation.

-- 
js
