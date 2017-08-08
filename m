From: David Ahern <dsahern@gmail.com>
Subject: Re: l3mdev: Support for sockets bound to enslaved device
Date: Tue, 8 Aug 2017 08:19:06 -0600
Message-ID: <db36b62f-bb8a-3948-d798-fdc39ccadf0d@gmail.com>
References: <20170808112958.ieexjwwgyp576kga@feanor.crfreenet.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ondrej Zajicek <santiago@crfreenet.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:34337 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752014AbdHHOTP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2017 10:19:15 -0400
Received: by mail-pf0-f169.google.com with SMTP id o86so15192715pfj.1
        for <netdev@vger.kernel.org>; Tue, 08 Aug 2017 07:19:15 -0700 (PDT)
In-Reply-To: <20170808112958.ieexjwwgyp576kga@feanor.crfreenet.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/8/17 5:29 AM, Ondrej Zajicek wrote:
> Hi
> 
> We noticed that TCP outgoing sockets that are bound to enslaved devices
> by SO_BINDTODEVICE fail to connect, while they work when bound to vrf
> device instead. We noticed similar behavior on ICMP (i.e. ping -I vrf0
> worked, while ping -I eth0 does not if eth0 is enslaved to vrf0). On
> the contrary, UDP outgoing sockets bound to enslaved devices worked
> as expected. We tested that on Linux 4.9.30-2 from Debian.
> 
> I found your patchset 'Support for sockets bound to enslaved device'
> ( http://www.spinics.net/lists/netdev/msg448040.html ), which seems
> to be related to the issue, but the description mentions services,
> i.e. listening sockets. Does the patchset (or some other one) fixes
> the issue also for outgoing sockets?
> 

Yes, it works for both directions.
