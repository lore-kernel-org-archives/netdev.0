From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH iproute2] Enable use of extra debugging information
Date: Wed, 22 Jun 2016 10:55:34 -0600
Message-ID: <f7d1368f-c71e-d2fe-bf79-caa631f4ecc9@cumulusnetworks.com>
References: <1466551629-7921-1-git-send-email-dsa@cumulusnetworks.com>
 <87oa6tmxgo.fsf@frog.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
To: Jakub Sitnicki <jkbs@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f51.google.com ([209.85.214.51]:35566 "EHLO
	mail-it0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751080AbcFVQzi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 12:55:38 -0400
Received: by mail-it0-f51.google.com with SMTP id g127so49101004ith.0
        for <netdev@vger.kernel.org>; Wed, 22 Jun 2016 09:55:37 -0700 (PDT)
In-Reply-To: <87oa6tmxgo.fsf@frog.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/22/16 2:36 AM, Jakub Sitnicki wrote:
>> diff --git a/Makefile b/Makefile
>> index 15c81ecfdca3..8e006759079d 100644
>> --- a/Makefile
>> +++ b/Makefile
>> @@ -39,7 +39,11 @@ HOSTCC = gcc
>>  DEFINES += -D_GNU_SOURCE
>>  # Turn on transparent support for LFS
>>  DEFINES += -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE
>> +ifdef DEBUG
>> +CCOPTS = -g
>> +else
>>  CCOPTS = -O2
>> +endif
>>  WFLAGS := -Wall -Wstrict-prototypes  -Wmissing-prototypes
>>  WFLAGS += -Wmissing-declarations -Wold-style-definition -Wformat=2
>
> This implies a change of optimization level to -O0 when building with
> DEBUG set, doesn't it? Was it intentional?

yes it is intentional.


> Perhaps it would be less surprising to explicitly set -O0, if that was
> your intention. Just a thought.
>
> Thanks,
> Jakub
>
