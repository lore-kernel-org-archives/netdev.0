From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: sctp: deny peeloff operation on asocs with threads sleeping on it
Date: Thu, 20 Apr 2017 10:54:42 -0300
Message-ID: <273c17d9-d424-ae4d-f282-976b7a1daa8a@gmail.com>
References: <20170420114405.mh7r5otmvpksacqd@lorien.valinor.li>
 <20170420123257.GA11798@lorien.valinor.li>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexander Popov <alex.popov@linux.com>,
        Ben Hutchings <ben@decadent.org.uk>,
        Xin Long <lucien.xin@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: Salvatore Bonaccorso <carnil@debian.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:33851 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1031195AbdDTNyu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 09:54:50 -0400
Received: by mail-qk0-f195.google.com with SMTP id d80so2908195qke.1
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 06:54:50 -0700 (PDT)
In-Reply-To: <20170420123257.GA11798@lorien.valinor.li>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em 20-04-2017 09:32, Salvatore Bonaccorso escreveu:
> Hi
> 
> According to the documentation I should have sent this to
> netdev@vger.kernel.org rather than stable@vger.kernel.org.
> 
> Rationale: Whilst 00eff2ebbd229758e90659907724c14dd5a18339 went to
> stable, the dfcb9f4f99f1e9a49e43398a7bfbf56927544af1 commit is
> missing.

Cc'ing Greg too.

This is probably because I noticed this commit was missing when Greg 
posted the commits being considered for backports, then I raised the 
concern and Greg decided to pull it too before David replied.

Not sure if this caused some out-of-the-process stuff.

> 
> Full quoting, my original misleaded mail:
> 
> On Thu, Apr 20, 2017 at 01:44:05PM +0200, Salvatore Bonaccorso wrote:
>> Hi
>>
>> Apparently the following commit
>>
>> dfcb9f4f99f1e9a49e43398a7bfbf56927544af1 (sctp: deny peeloff operation
>> on asocs with threads sleeping on it)
>>
>> (was not CC'ed stable@vger.kernel.org, but was already applied in
>> 3.2.87 and 3.16.42) is missing from 4.9:
>>
>> 2dcab598484185dea7ec22219c76dcdd59e3cb90 was included in 4.9.11 via
>> 00eff2ebbd229758e90659907724c14dd5a18339 . But
>> dfcb9f4f99f1e9a49e43398a7bfbf56927544af1 is missing from 4.9.
>>
>> This was assigned CVE-2017-6353.
>>
>> Reference:
>> https://marc.info/?l=linux-netdev&m=148785309416337&w=2
>> http://www.openwall.com/lists/oss-security/2017/02/27/2
>>
>> Regards,
>> Salvatore
> 
> Regards,
> Salvatore
> 
