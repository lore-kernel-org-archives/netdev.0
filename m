From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch] netfilter: default to NF_DROP in sip_help_tcp()
Date: Wed, 04 Aug 2010 18:10:42 +0200
Message-ID: <4C599102.9050500@trash.net>
References: <20100710031604.GA26990@verge.net.au> <4C3DAC25.3050401@trash.net> <20100804080742.GC10740@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51243 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755958Ab0HDQKq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Aug 2010 12:10:46 -0400
In-Reply-To: <20100804080742.GC10740@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 04.08.2010 10:07, schrieb Simon Horman:
> On Wed, Jul 14, 2010 at 02:23:01PM +0200, Patrick McHardy wrote:
>> On 10.07.2010 05:16, Simon Horman wrote:
>>> I initially noticed this because of the compiler warning below, but it does
>>> seem to be a valid concern in the case where ct_sip_get_header() returns 0
>>> in the first iteration of the while loop.
>>>
>>> net/netfilter/nf_conntrack_sip.c: In function 'sip_help_tcp':
>>> net/netfilter/nf_conntrack_sip.c:1379: warning: 'ret' may be used uninitialized in this function
>>
>> Thanks Simon. I've applied the patch, but changed NF_DROP to
>> NF_ACCEPT since we should avoid dropping packets with unknown
>> contents (not SIP) if possible.
> 
> Hi Patrick,
> 
> I'm not seeing this patch in nf-next-2.6.
> Am I looking in the wrong place?

I was struggling with some file system corruption and didn't manage
to send it out in time, sorry. I'll include it in the next batch of
patches for .36 and will also push it to -stable.
