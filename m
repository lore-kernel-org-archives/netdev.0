From: Sowmini Varadhan <sowmini05@gmail.com>
Subject: Re: ARP response with link local IP, why not broadcast
Date: Tue, 21 Jul 2015 21:39:06 +0200
Message-ID: <CACP96tRrCzFwTC-fSMxGTWr+zFSkid=Bd6JkGZA822HbEjk4_Q@mail.gmail.com>
References: <55AE5958.3020009@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Sebastian Fett <db_extern@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:37072 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752230AbbGUTjH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 15:39:07 -0400
Received: by wibud3 with SMTP id ud3so140494610wib.0
        for <netdev@vger.kernel.org>; Tue, 21 Jul 2015 12:39:06 -0700 (PDT)
In-Reply-To: <55AE5958.3020009@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 21, 2015 at 4:38 PM, Sebastian Fett <db_extern@gmx.de> wrote:
> Hello!
>
> According to RFC3927 every ARP packet (reply and request) should be sent as
> link layer broadcast as long as the sender IP is a link local address. (see
> chapter 2.5).

Because broadcast replies are noisy and should be avoided.
if possible- it creates a broadcast flood that would wake up all receivers,
and is especially undesirable in today's world, where bcast would wake
up sleepy devices, or require other inefficient processes in a cloud env.
See also https://www.ietf.org/id/draft-nordmark-6man-dad-approaches-01.txt

> That functionality would help me a lot with a use case I have with our
> application.

what is your use case?

>
> But it is not implemented in the kernel that way.
> Does anyone know why?

--Sowmini
