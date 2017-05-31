From: Ben Greear <greearb@candelatech.com>
Subject: Re: 'iw events' stops receiving events after a while on 4.9 + hacks
Date: Wed, 31 May 2017 06:46:53 -0700
Message-ID: <6df299af-c053-9b60-19b9-8fb187d75d22@candelatech.com>
References: <d82d191e-8ede-68c6-c9e0-c381dc874d36@candelatech.com>
 <20170517100844.GC2849@medion.lan>
 <1495027835.2442.13.camel@sipsolutions.net>
 <fa96dfad-8d1b-c48f-df3b-3df0d548a5c6@candelatech.com>
 <1496150322.3327.9.camel@sipsolutions.net> <20170531081836.GC2849@medion.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>
To: Bastian Bittorf <bb@npl.de>,
        Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:58840 "EHLO
        mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750878AbdEaNqz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 09:46:55 -0400
In-Reply-To: <20170531081836.GC2849@medion.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 05/31/2017 01:18 AM, Bastian Bittorf wrote:
> * Johannes Berg <johannes@sipsolutions.net> [31.05.2017 10:09]:
>>> Is there any way to dump out the socket information if we reproduce
>>> the problem?
>>
>> I have no idea, sorry.
>>
>> If you or Bastian can tell me how to reproduce the problem, I can try
>> to investigate it.
>
> there was an interesting fix regarding the shell-builtin 'read' in
> busybox[1]. I will retest again and report if this changes anything.
>
> bye, bastian
>
> PS: @ben: are you also using 'iw event | while read -r LINE ...'?

I'm using a perl script to read the output, and not using busybox.

I have not seen the problem again, so it is not easy for me to reproduce.

If you reproduce it, maybe check 'strace' on the 'iw' process to see if it is
hung on writing output to the pipe or reading input?  In my case, it appeared
to be hung reading input from netlink, input that never arrived.

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
