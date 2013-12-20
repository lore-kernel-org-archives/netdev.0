From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH 2/2] net_sched: optimize tcf_match_indev()
Date: Fri, 20 Dec 2013 07:14:33 -0500
Message-ID: <52B434A9.9070408@mojatatu.com>
References: <1387503292-20078-1-git-send-email-xiyou.wangcong@gmail.com>	<1387503292-20078-2-git-send-email-xiyou.wangcong@gmail.com>	<1387520573.19078.424.camel@edumazet-glaptop2.roam.corp.google.com>	<CAM_iQpWA2qjjEV97SFajg0Y_0WnWAY2qPY9_7vSuFVuYq5tH6Q@mail.gmail.com>	<1387522459.19078.427.camel@edumazet-glaptop2.roam.corp.google.com> <CAM_iQpX-Ghj8K-3i4ph+ArugbxjoyZiYDkc1jxBEE+YjmYv3eg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:56165 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932130Ab3LTMOg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 07:14:36 -0500
Received: by mail-ig0-f169.google.com with SMTP id hk11so14758096igb.0
        for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 04:14:35 -0800 (PST)
In-Reply-To: <CAM_iQpX-Ghj8K-3i4ph+ArugbxjoyZiYDkc1jxBEE+YjmYv3eg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/20/13 03:12, Cong Wang wrote:
> On Thu, Dec 19, 2013 at 10:54 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> On Thu, 2013-12-19 at 22:36 -0800, Cong Wang wrote:
>>
>>> Hmm, off-by-one error, stupid me.
>>
>> There is something else.
>>
>> Its late here, I'll let you find and fix the problems.
>>
>
> I just sent a fix for the problem I see, not sure it fixes
> the bug you reported too.
>
> I will test it as a module tomorrow, if you don't send a fix
> before that.
>

Very impressive catch Eric. I would have 100% caught this with testing
(but you caught it by inspecting code!).
A simple test that dumps all the actions of a specific type would do.
Example in your case, Cong:
tc actions ls action mirred

[I dont want to sound passive aggressive (a Canadian right, of course),
but this is why i get nervous about big changes like these which dont 
undergo more testing time.]

cheers,
jamal
