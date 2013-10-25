From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: Re: Odd SCTP behaviour after remote host reboot.
Date: Fri, 25 Oct 2013 08:36:30 -0400
Message-ID: <CAGCdqXFqLSzyLkb4Ts5w7sCV0WDrEAQ0t8WhVJFLJox=gy9OdQ@mail.gmail.com>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B73B3@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f169.google.com ([74.125.82.169]:49118 "EHLO
	mail-we0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751691Ab3JYMgc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Oct 2013 08:36:32 -0400
Received: by mail-we0-f169.google.com with SMTP id q58so3791900wes.14
        for <netdev@vger.kernel.org>; Fri, 25 Oct 2013 05:36:30 -0700 (PDT)
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B73B3@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 25, 2013 at 6:19 AM, David Laight <David.Laight@aculab.com> wrote:
> I've just been given a very odd Wireshark trace from a customer.
>
> There is a single SCTP association with src_port==dst_port=5104 (m3ua).
> The remote system is reset and establishes a new association with the
> same port numbers.
> (The trace shows init/init_ack/cookie/cookie_ack with new verification tags.)
> However the data seems to have been linked back to the original socket!
> There are no further packets sent with the old verification tag.
>
> This isn't what I expect, and seems inappropriate for a reliable transport.
>
> The kernel they are running is old - 2.6.18-164 RHEL 5 update 4 from 2009!
> My guess is that it won't include any SCTP updates - so the latest RHEL 5
> kernel (2.6.18-358) won't be any better.
>
> Any idea when this might have been fixed?
> If they want to use RH, the latest kernel is based on 2.6.32.

This sounds like a problem with restarts that (according to git) was fixed
in 2.6.22.

-vlad
