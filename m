From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH iproute2 net-next] ifstat: move to new RTM_GETSTATS api
Date: Mon, 9 May 2016 08:38:04 -0400
Message-ID: <573084AC.6030407@mojatatu.com>
References: <1461998511-24193-1-git-send-email-roopa@cumulusnetworks.com>
 <57248720.8060001@mojatatu.com> <5724CC01.3030203@cumulusnetworks.com>
 <573016F1.8050700@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	davem@davemloft.net, edumazet@google.com, tgraf@suug.ch,
	nicolas.dichtel@6wind.com, nikolay@cumulusnetworks.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:35927 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751421AbcEIMiH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 08:38:07 -0400
Received: by mail-ig0-f182.google.com with SMTP id u10so102617363igr.1
        for <netdev@vger.kernel.org>; Mon, 09 May 2016 05:38:07 -0700 (PDT)
In-Reply-To: <573016F1.8050700@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-05-09 12:49 AM, Roopa Prabhu wrote:
> On 4/30/16, 8:15 AM, Roopa Prabhu wrote:
>> On 4/30/16, 3:21 AM, Jamal Hadi Salim wrote:

> AFAICS ifstat history file handling today assumes all 32 bit stats.

Indeed it does.

> And to preserve backward compatibility, new ifstat should work with old and
> new history files with 32bit and 64 bit stats.

True.
It may be ok to just provide a conversion tool maybe for taking 32b
history into 64b? I dont know if someone is going to "migrate" their
history files so even that may not be worth it.

> The file format cannot be changed because of the same backward compat issues.
> So, I am leaning towards a new history file with a new option (maybe ifstat -64) to
> save/query 64 bit stats using the new api when available.
>
> I see some previous brief discussions on moving ifstat to 64 bit.
>
> The other option is to only change 'ip -s link show' to use the new stats api.
>
> let me know if there are other thoughts.
>

Is it not possible to convert to 64b - and IFLA_STAT
becomes available just store it still in 64b?
i.e 32b will fit in 64b space.

cheers,
jamal
