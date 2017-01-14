From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] atm: remove an unnecessary loop
Date: Fri, 13 Jan 2017 16:36:07 -0800
Message-ID: <CAM_iQpVKkroPsdfkHRoVTLzoWeF-oXPGiyZJ7LkNZfRmLdG3Ow@mail.gmail.com>
References: <CAM_iQpXd8qTTRT_+CkHnpMNC=CSS9vfB6zKtSjmLV_yya5BL8Q@mail.gmail.com>
 <20170114001422.GA6874@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Michal Hocko <mhocko@kernel.org>,
        Chas Williams <3chas3@gmail.com>,
        Andrey Konovalov <andreyknvl@google.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:35051 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750809AbdANAg2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 19:36:28 -0500
Received: by mail-qk0-f195.google.com with SMTP id u25so9274071qki.2
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2017 16:36:28 -0800 (PST)
In-Reply-To: <20170114001422.GA6874@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 13, 2017 at 4:14 PM, Francois Romieu <romieu@fr.zoreil.com> wrote:
> Cong Wang <xiyou.wangcong@gmail.com> :
> [...]
>> If you can justify API is not broken by doing that, I am more than happy
>> to do it, as I already stated in the latter patch:
>>
>> "Of course, the logic itself is suspicious, other sendmsg()
>> could handle skb allocation failure very well, not sure
>> why ATM has to wait for a successful one here. But probably
>> it is too late to change since the errno and behavior is
>> visible to user-space. So just leave the logic as it is."
>>
>> For some reason, no one reads that patch. :-/
>
> Believe it or not but I actually read it.
>
> It changes the logic : the original code would have been unable to
> escape the while loop on memory failure. Fine, I don't mind the change.
> Actually I believe that these two patches are too shy (and backport
> unefficient). Instead of trying to reformulate why, here's what I have
> in mind. Uncompiled, caveat emptor, etc.

I just don't want to break things, that is it. If you can convince me your
change will not break any user-space application, again I am more
than just happy about it. My ATM knowledge is close to zero. ;)
