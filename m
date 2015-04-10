From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: EACCES sending UDP to broadcast address?
Date: Thu, 09 Apr 2015 18:12:42 -0700
Message-ID: <1428628362.25985.284.camel@edumazet-glaptop2.roam.corp.google.com>
References: <552721AC.9080900@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:33835 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752004AbbDJBMp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 21:12:45 -0400
Received: by iedfl3 with SMTP id fl3so7197399ied.1
        for <netdev@vger.kernel.org>; Thu, 09 Apr 2015 18:12:45 -0700 (PDT)
In-Reply-To: <552721AC.9080900@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-04-09 at 18:04 -0700, Ben Greear wrote:
> I'm running as root user, 4.0-rc6 + hack kernel.
> 
> User-space app is (or should be) trying to send a UDP frame
> to 255.255.255.255 destination.
> 
> I am getting EACCESS from sendmmsg.
> 
> Is this expected?  Is there something even more special than root these
> days?

man 7 socket

       SO_BROADCAST
              Set  or  get  the  broadcast flag.  When enabled, datagram
sockets are allowed to send packets to a broadcast address.  This option
has no effect on stream-oriented
              sockets.



root user still has to use this option.
