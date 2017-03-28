From: Salam Noureddine <noureddine@arista.com>
Subject: Re: Null pointer dereference in tg3_poll_work running linux-3.4
Date: Tue, 28 Mar 2017 15:12:43 -0700
Message-ID: <CAO7SqHB5rLKGoVKAifiggDEA1itQNmy7qPVyYht47AYqvNdN6A@mail.gmail.com>
References: <CAO7SqHCqADHoZMy7+quaF83-Ln24A=xx10D1Tv9=SX5DFsncpg@mail.gmail.com>
 <CACKFLinE3PYyQwcF+CYAcJF=wFz6V58DHWF45WVof+JUn0g8dQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
        "michael.chan@broadcom.com" <mchan@broadcom.com>,
        "prashant.sreedharan@broadcom.com" <prashant@broadcom.com>,
        Siva Reddy Kallam <siva.kallam@broadcom.com>
To: Michael Chan <michael.chan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f48.google.com ([209.85.213.48]:35188 "EHLO
        mail-vk0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932157AbdC1WMp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 18:12:45 -0400
Received: by mail-vk0-f48.google.com with SMTP id r69so105185095vke.2
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 15:12:44 -0700 (PDT)
In-Reply-To: <CACKFLinE3PYyQwcF+CYAcJF=wFz6V58DHWF45WVof+JUn0g8dQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 28, 2017 at 11:53 AM, Michael Chan
<michael.chan@broadcom.com> wrote:

> I don't remember any bug fixes related to this logic.  One possibility
> is that there is DMA corruption and we are getting a bad opaque value.
> If you have the core dump, it will be useful to look at the receive
> completion ring.   These opaque values are simple index values and
> should be in sequence.

Unfortunately I don't have a core dump, this has happened around 5
times on boxes that have been up between 2 and 7 months. So it
seems extremely rare. So far, the only information I have is the
stack trace.
