From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Why max netlink msg size is limited to 16k
Date: Sat, 22 Apr 2017 08:36:21 -0700
Message-ID: <1492875381.6453.34.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CA+VDgmNYc=djp6ab=n49CTpyvof8CPgHvXRst5Vnm706e-nRvQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: prashantkumar dhotre <prashantkumardhotre@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f48.google.com ([209.85.214.48]:38564 "EHLO
        mail-it0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1425091AbdDVPgY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Apr 2017 11:36:24 -0400
Received: by mail-it0-f48.google.com with SMTP id e132so14799913ite.1
        for <netdev@vger.kernel.org>; Sat, 22 Apr 2017 08:36:24 -0700 (PDT)
In-Reply-To: <CA+VDgmNYc=djp6ab=n49CTpyvof8CPgHvXRst5Vnm706e-nRvQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2017-04-22 at 19:43 +0530, prashantkumar dhotre wrote:
> I am observing that max netlink msg that my kernel module can send to
> user app is close to 16K.
> 
> For larger sizes, genlmsg_unicast() succeeds but my app does not receive data.
> 
> I have tried increasing RECV buffer size in my user app but that does not help.
> 
> Regards


You need a kernel >= linux-4.9 to get about 32KB 

Why is this limited ? Please read 

https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git/commit/?id=d35c99ff77ecb2eb239731b799386f3b3637a31e
