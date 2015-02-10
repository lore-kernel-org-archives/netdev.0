From: Bryton Lee <brytonlee01@gmail.com>
Subject: Re: [PATCH] prevent the read ahead of /proc/slabinfo in ss
Date: Tue, 10 Feb 2015 10:01:06 +0800
Message-ID: <CAC2pzGf5=XCxLbjX41c8CXkoh2s26PHLHX+tGOJyqEUnwVAfOg@mail.gmail.com>
References: <1423481830-9599-1-git-send-email-brytonlee01@gmail.com>
	<20150209.111618.1959932896181412008.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:45367 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752506AbbBJCBH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2015 21:01:07 -0500
Received: by pdbnh10 with SMTP id nh10so32888698pdb.12
        for <netdev@vger.kernel.org>; Mon, 09 Feb 2015 18:01:07 -0800 (PST)
In-Reply-To: <20150209.111618.1959932896181412008.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 10, 2015 at 3:16 AM, David Miller <davem@davemloft.net> wrote:
> From: Bryton Lee <brytonlee01@gmail.com>
> Date: Mon,  9 Feb 2015 19:37:10 +0800
>
>> @@ -617,6 +617,7 @@ struct slabstat
>>  };
>>
>>  struct slabstat slabstat;
>> +int slabstat_valid = 0;
>>
>>  static const char *slabstat_ids[] =
>>  {
>
> Nothing sets this to a non-zero value.  If nothing is going to set it to
> a non-zero value, the code it guards should simple be removed instead.
>
when ss runs witch -s paramater slabstat will be used, and if kernel
not support NETLINK ss -t will use slabstat too.  so it's not nothing
sets this to a non-zero value.

> Otherwise, nothing uses this variable outside of this file, and if
> that's intentional it should be static.

Yes, these should be changed to static,  I will submit these change
soon.  thanks!



-- 
Best Regards

Bryton.Lee
