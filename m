From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH][net-next] net: avoid to call skb_queue_len again
Date: Mon, 08 Dec 2014 14:28:22 +0300
Message-ID: <54858B56.1020607@cogentembedded.com>
References: <1417772948-17909-1-git-send-email-roy.qing.li@gmail.com>	<5481BBF2.40806@cogentembedded.com>	<1417789870.15618.1.camel@edumazet-glaptop2.roam.corp.google.com> <CAJFZqHzeESfMBqb1gQr4DsE-v_fSfUX+AyWbt_VriJJ8Dj2FnA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Li RongQing <roy.qing.li@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f51.google.com ([209.85.215.51]:39754 "EHLO
	mail-la0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752111AbaLHL2W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2014 06:28:22 -0500
Received: by mail-la0-f51.google.com with SMTP id ms9so3714405lab.24
        for <netdev@vger.kernel.org>; Mon, 08 Dec 2014 03:28:21 -0800 (PST)
In-Reply-To: <CAJFZqHzeESfMBqb1gQr4DsE-v_fSfUX+AyWbt_VriJJ8Dj2FnA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12/8/2014 3:46 AM, Li RongQing wrote:

>>>> From: Li RongQing <roy.qing.li@gmail.com>

>>>> the queue length of sd->input_pkt_queue has been putted into qlen,

>>>      s/putted/put/, it's irregular verb.

> I will fix it and  resend this patch

>>>> and impossible to change, since hold the lock

>>>      I can't parse that. Who holds the lock?

>> This thread/cpu holds the lock to manipulate input_pkt_queue.

>> Otherwise, the following would break horribly....

>> __skb_queue_tail(&sd->input_pkt_queue, skb);

> Thanks Eric

    I expect you to also refine the description, so that it's meaningful, 
unlike now.

> -Roy

WBR, Sergei
