From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch iproute2] u32: add terminal parameter
Date: Mon, 14 Apr 2014 18:57:48 -0700
Message-ID: <CAM_iQpV8GeEQr+GFFy2Etct_51YhvXEBKydyH9q4NP5QbsDOnA@mail.gmail.com>
References: <1396631826-15188-1-git-send-email-xiyou.wangcong@gmail.com>
	<20140411140446.6412e9dc@nehalam.linuxnetplumber.net>
	<CAM_iQpVpNOJ1xiK45qXGRXgBZ2QcmwoPc7p=SOHCo=1kTwPfFQ@mail.gmail.com>
	<20140411175800.08e9ffe3@nehalam.linuxnetplumber.net>
	<CAM_iQpU7Ntn-yo-ez0vP2BhKe+-Vaq1w_+MQhFPHM-bbQZx2gg@mail.gmail.com>
	<534926F7.10505@mojatatu.com>
	<CAM_iQpXJnOOUbpS0WwrB7C50LGxcLhMEQPrDB84Zm-SLKVHh6w@mail.gmail.com>
	<534C6BDE.8020600@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f42.google.com ([209.85.219.42]:36624 "EHLO
	mail-oa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750790AbaDOB5t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2014 21:57:49 -0400
Received: by mail-oa0-f42.google.com with SMTP id i4so10062482oah.15
        for <netdev@vger.kernel.org>; Mon, 14 Apr 2014 18:57:49 -0700 (PDT)
In-Reply-To: <534C6BDE.8020600@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 14, 2014 at 4:14 PM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 04/14/14 17:18, Cong Wang wrote:
>>
>> On Sat, Apr 12, 2014 at 4:43 AM, Jamal Hadi Salim <jhs@mojatatu.com>
>> wrote:
>
>
>> Why? The qdisc my u32 filters attached to is classless (ingress).
>
>
> flowid is a filter id. I am almost certain it was a mistake on your
> part to leave it out. This is why i called it an FAQ and suggested
> you provide a patch to block people from leaving it out.
>
>

So essentially why u32 filters can't just do matching without bothering
classid especially when they are attached to an ingress qdisc? I still
fail to see a reason why I have to care about classid here.
