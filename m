From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH 1/2] ip_tunnel: GSO: Add check for nested encap.
Date: Thu, 12 Jun 2014 08:35:45 -0700
Message-ID: <CALnjE+oAR0O_iYRSK2hCqio3Rte99Shz4qCSh3pqgJjSVUmP7w@mail.gmail.com>
References: <1401017972-1544-1-git-send-email-pshelar@nicira.com>
	<20140610.222120.1648194413371340927.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog101.obsmtp.com ([74.125.149.67]:49341 "HELO
	na3sys009aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756441AbaFLPfr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2014 11:35:47 -0400
Received: by mail-vc0-f179.google.com with SMTP id id10so968375vcb.38
        for <netdev@vger.kernel.org>; Thu, 12 Jun 2014 08:35:46 -0700 (PDT)
In-Reply-To: <20140610.222120.1648194413371340927.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 10, 2014 at 10:21 PM, David Miller <davem@davemloft.net> wrote:
> From: Pravin B Shelar <pshelar@nicira.com>
> Date: Sun, 25 May 2014 04:39:32 -0700
>
>> +     if (skb_is_gso(skb)) {
>> +             if (unlikely(skb->encapsulation)) {
>> +                     /* Current networking GSO stack can handle
>> +                      * only one level of encapsulation. */
>> +                     err = -ENOSYS;
>> +                     goto error;
>> +             }
>
> This is not the correct way to format a comment in the kernel networking
> code, the proper way is:
>
>         /* Like
>          * this.
>          */
>
> Also, you need to provide a cover posting for a patch series explaining
> at a high level what this patch series is accomplishing.  Also you need
> to explicitly indicate what tree this set of changes is targetting.
>

Sorry, I will send updated patch. Lately I been working mostly on
ovs-dev so I missed few conventions.
