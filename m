From: Li RongQing <roy.qing.li@gmail.com>
Subject: Re: [PATCH][net-next] net: avoid to call skb_queue_len again
Date: Mon, 8 Dec 2014 08:46:47 +0800
Message-ID: <CAJFZqHzeESfMBqb1gQr4DsE-v_fSfUX+AyWbt_VriJJ8Dj2FnA@mail.gmail.com>
References: <1417772948-17909-1-git-send-email-roy.qing.li@gmail.com>
	<5481BBF2.40806@cogentembedded.com>
	<1417789870.15618.1.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f170.google.com ([209.85.216.170]:62682 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752243AbaLHAqs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Dec 2014 19:46:48 -0500
Received: by mail-qc0-f170.google.com with SMTP id x3so2902311qcv.1
        for <netdev@vger.kernel.org>; Sun, 07 Dec 2014 16:46:47 -0800 (PST)
In-Reply-To: <1417789870.15618.1.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 5, 2014 at 10:31 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2014-12-05 at 17:06 +0300, Sergei Shtylyov wrote:
>> Hello.
>>
>> On 12/5/2014 12:49 PM, roy.qing.li@gmail.com wrote:
>>
>> > From: Li RongQing <roy.qing.li@gmail.com>
>>
>> > the queue length of sd->input_pkt_queue has been putted into qlen,
>>
>>     s/putted/put/, it's irregular verb.
>>

I will fix it and  resend this patch


>> > and impossible to change, since hold the lock
>>
>>     I can't parse that. Who holds the lock?
>
> This thread/cpu holds the lock to manipulate input_pkt_queue.
>
> Otherwise, the following would break horribly....
>
> __skb_queue_tail(&sd->input_pkt_queue, skb);
>
>

Thanks Eric


-Roy
>
