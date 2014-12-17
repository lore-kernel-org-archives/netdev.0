From: Dennis Chen <kernel.org.gnu@gmail.com>
Subject: Re: [Question]The benefit of weight_p in __qdisc_run
Date: Wed, 17 Dec 2014 17:32:55 +0800
Message-ID: <CA+U0gVhtc=ZzqY6OXamawxz4qvi_BCcoisr4=4scdc=xUKAeyw@mail.gmail.com>
References: <CA+U0gVhk+4-T=XuCumnpRnRyQ=OqVfegGxF3ZZQy07++PDOW3g@mail.gmail.com>
 <54914AEC.7070600@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:45344 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751082AbaLQJdQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2014 04:33:16 -0500
Received: by mail-pa0-f47.google.com with SMTP id kq14so16058222pab.20
        for <netdev@vger.kernel.org>; Wed, 17 Dec 2014 01:33:15 -0800 (PST)
In-Reply-To: <54914AEC.7070600@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 17, 2014 at 5:20 PM, Daniel Borkmann <dborkman@redhat.com> wrote:
> On 12/17/2014 09:54 AM, Dennis Chen wrote:
>>
>> weight_p is used as the burst xmit packet quota in the while loop of
>> the __qdisc_run function,
>> does anybody can elaborate the benefit of the weight_p introduced
>> here? what's the consequence without it?
>
>
> It acts as a quota to introduce fairness among qdiscs. See also slide 7
> onwards for experiments with/without it:
>
>   http://vger.kernel.org/netconf2011_slides/jamal_netconf2011.pdf

Dan, I really do appreciate for your answer :)

-- 
Den
