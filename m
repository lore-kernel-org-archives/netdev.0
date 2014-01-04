From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch iproute2 v2 0/2] add support for IFA_F_MANAGETEMPADDR
Date: Sat, 4 Jan 2014 11:43:31 +0100
Message-ID: <20140104104331.GB9295@minipsycho.orion>
References: <1388676879-2603-1-git-send-email-jiri@resnulli.us>
 <20140102172949.GF22494@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	thaller@redhat.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f49.google.com ([74.125.83.49]:51542 "EHLO
	mail-ee0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750873AbaADKne (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jan 2014 05:43:34 -0500
Received: by mail-ee0-f49.google.com with SMTP id c41so7039631eek.22
        for <netdev@vger.kernel.org>; Sat, 04 Jan 2014 02:43:33 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20140102172949.GF22494@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Jan 02, 2014 at 06:29:49PM CET, hannes@stressinduktion.org wrote:
>On Thu, Jan 02, 2014 at 04:34:37PM +0100, Jiri Pirko wrote:
>> v1->v2: Removed 0xff masking of ifa_flags
>> 
>> Jiri Pirko (2):
>>   add support for extended ifa_flags
>>   add support for IFA_F_MANAGETEMPADDR
>> 
>>  include/linux/if_addr.h |  2 ++
>>  ip/ipaddress.c          | 50 +++++++++++++++++++++++++++++++++++--------------
>>  2 files changed, 38 insertions(+), 14 deletions(-)
>
>I still wonder how source address selection should work for
>IFA_F_MANAGETEMPADDR if use_tempaddr != 2 mode is not available for
>those addresses.
>
>Up until now applications can bind to those addresses and traffic can be
>received for them, but there is now way how a user can specify to favor them
>in case of use_tempaddr == 0.

I'm not sure I understand you. Can you please elaborate more? Not sure
how this is related to iproute2.

Anyway, the kernel behaviour wrt use_tempaddr settings remains unchanged
with the addition of IFA_F_MANAGETEMPADDR. It only allows to create temp
addresses for other addresses than the ones created by kernel (by RA).

Jiri
	
>
>Greetings,
>
>  Hannes
>
