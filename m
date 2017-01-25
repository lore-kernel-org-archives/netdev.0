From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP stops sending packets over loopback on 4.10-rc3?
Date: Wed, 25 Jan 2017 06:39:59 -0800
Message-ID: <1485355199.5145.14.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1485256853.4014.0@smtp.office365.com>
         <1485266868.16328.292.camel@edumazet-glaptop3.roam.corp.google.com>
         <1485353664.5902.2@smtp.office365.com>
         <1485354408.5902.3@smtp.office365.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
        Lawrence Brakmo <brakmo@fb.com>,
        Kernel Team <kernel-team@fb.com>
To: Josef Bacik <jbacik@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35597 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751385AbdAYOkB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 09:40:01 -0500
Received: by mail-pf0-f194.google.com with SMTP id f144so14532431pfa.2
        for <netdev@vger.kernel.org>; Wed, 25 Jan 2017 06:40:01 -0800 (PST)
In-Reply-To: <1485354408.5902.3@smtp.office365.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-01-25 at 09:26 -0500, Josef Bacik wrote:

> Nope ftrace isn't broken, I'm just dumb, the space is being reclaimed 
> by sk_wmem_free_skb().  So I guess I need to figure out why I stop 
> getting ACK's from the other side of the loopback.  Thanks,

ss -temoi dst 127.0.0.1

Might give you some hints, like packets being dropped.

ACK can be delayed if the reader is slow to consume bytes.
