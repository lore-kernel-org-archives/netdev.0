From: Erik Kline <ek@google.com>
Subject: Re: [RFC PATCH net-next] net: ipv6: Add a sysctl to make optimistic
 addresses useful candidates
Date: Tue, 21 Oct 2014 13:02:02 +0900
Message-ID: <CAAedzxqKcTLHNA+JBVA3ORPUfOqN5h2z=pg_Gzi30G-9vYH+Zg@mail.gmail.com>
References: <1413520309-13814-1-git-send-email-ek@google.com> <1413844815.31953.32.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
	Lorenzo Colitti <lorenzo@google.com>,
	Eric Dumazet <edumazet@google.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f170.google.com ([209.85.216.170]:60465 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750730AbaJUECY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2014 00:02:24 -0400
Received: by mail-qc0-f170.google.com with SMTP id m20so298981qcx.29
        for <netdev@vger.kernel.org>; Mon, 20 Oct 2014 21:02:23 -0700 (PDT)
In-Reply-To: <1413844815.31953.32.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks.  Patch v2 coming shortly.

On Tue, Oct 21, 2014 at 7:40 AM, Ben Hutchings <ben@decadent.org.uk> wrote:
> On Fri, 2014-10-17 at 13:31 +0900, Erik Kline wrote:
> [...]
>> --- a/include/uapi/linux/ipv6.h
>> +++ b/include/uapi/linux/ipv6.h
>> @@ -154,6 +154,7 @@ enum {
>>       DEVCONF_ACCEPT_RA_RT_INFO_MAX_PLEN,
>>       DEVCONF_PROXY_NDP,
>>       DEVCONF_OPTIMISTIC_DAD,
>> +     DEVCONF_USE_OPTIMISTIC,
>>       DEVCONF_ACCEPT_SOURCE_ROUTE,
>>       DEVCONF_MC_FORWARDING,
>>       DEVCONF_DISABLE_IPV6,
> [...]
>
> As this is UAPI, the new entry must be added at the end of the
> enumeration (well, before DEVCONF_MAX).
>
> Ben.
>
> --
> Ben Hutchings
> Reality is just a crutch for people who can't handle science fiction.
