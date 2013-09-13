From: Jeff Loughridge <jeffl@alumni.duke.edu>
Subject: Re: ip l2tp - suspected defect using IPv6 local/remote addresses
Date: Thu, 12 Sep 2013 20:46:55 -0400
Message-ID: <CAG2uBVfDg2yeWOgc+vdv_dUE8X042yufm9PUb2J8L2PoMY3VGw@mail.gmail.com>
References: <CAG2uBVfwNOj_jKvaHV_66qrrBU5adDoqDWMvV7seNWfsG4RVAQ@mail.gmail.com>
 <CAEwTi7Qo8=X=v51_1y3JMQnbG3xBQYRb9YRePFh6KfYmb_Y0-g@mail.gmail.com> <1378991941.1531.5.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: James Chapman <jchapman@katalix.com>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:49667 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750780Ab3IMArQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Sep 2013 20:47:16 -0400
Received: by mail-ie0-f173.google.com with SMTP id ar20so1220052iec.32
        for <netdev@vger.kernel.org>; Thu, 12 Sep 2013 17:47:16 -0700 (PDT)
In-Reply-To: <1378991941.1531.5.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I confirmed IPv6 endpoints work using a 3.5 kernel. Thanks, guys.

On Thu, Sep 12, 2013 at 9:19 AM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
> On Thu, 2013-09-12 at 11:20 +0100, James Chapman wrote:
>> On 11 September 2013 19:52, Jeff Loughridge <jeffl@alumni.duke.edu> wrote:
>> >
>> > Using IPv6 address as L2TPv3 endpoints doesn't seem to work in
>> > iproute2 3.11. I see a cosmetic defect in the output of 'ip l2tp show
>> > tunnel'. In addition, I can't get tunnels to function with UDP or IP
>> > encapsulation.
>> >
>> > root@debian:~# ip l2tp add tunnel tunnel_id 3000 peer_tunnel_id 4000
>> > encap udp local a::1 remote a::2 udp_sport 5000 udp_dport 6000
>> > root@debian:~# ip l2tp add session tunnel_id 3000 session_id 1000
>> > peer_session_id 2000
>> > root@debian:~# ip l2tp show tunnel
>> > Tunnel 3000, encap UDP
>> >   From 127.0.0.1 to 127.0.0.1
>> >   Peer tunnel 4000
>> >   UDP source / dest ports: 5000/6000
>> > root@debian:~#
>>
>> You'll need a 3.5 or later kernel for L2TP over IPv6. I see you are
>> using 3.2. Are you using a version of iproute2 which is not matched to
>> your kernel?
> [...]
>
> The iproute2 version number only indicates which kernel features it
> supports; it is supposed to be backward-compatible.  And it really
> should not silently fail like this, although this may well be a bug in
> the API that can't be fixed in userland...
>
> Ben.
>
> --
> Ben Hutchings, Staff Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
>
