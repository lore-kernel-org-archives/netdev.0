From: Varka Bhadram <varkabhadram@gmail.com>
Subject: Re: [PATCH net-next 1/2] ieee802154: removed unwanted header files
Date: Wed, 09 Jul 2014 09:57:08 +0530
Message-ID: <53BCC49C.5090503@gmail.com>
References: <1404877445-2757-1-git-send-email-varkab@cdac.in>	<1404877445-2757-2-git-send-email-varkab@cdac.in> <20140708.205605.1846044536261079477.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alex.aring@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, varkab@cdac.in
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:57194 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750915AbaGIE2Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2014 00:28:25 -0400
Received: by mail-pd0-f178.google.com with SMTP id r10so8219903pdi.23
        for <netdev@vger.kernel.org>; Tue, 08 Jul 2014 21:28:24 -0700 (PDT)
In-Reply-To: <20140708.205605.1846044536261079477.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/09/2014 09:26 AM, David Miller wrote:
> These changes are completely bogus.
>
> Where are the definitions of the data types for "struct in6_addr" and
> "struct ipv6hdr" coming from.
>
> I'm not even going to look at these patches until you:
>
> 1) Properly audit the files.  Removing an include and typing "make"
>     is not auditing the header file requriements.  Reading the code
>     and looking at where declarations and definitions actually come
>     from _is_.

I got your point. Thanks

>
> 2) Write a real commit message, this one is way too terse and tells me
>     nothing.  Explain why each header file was removed, and what the
>     justification is.

Ok i will explain about the changes. I thinks i have to change the entire
patch. I have to rework on it. Thanks


-- 
Regards,
Varka Bhadram.
