From: Tyler Bautista <tylerbautista@gmail.com>
Subject: Re: TC-pedit man page examples error
Date: Wed, 26 Jul 2017 09:47:51 -0700
Message-ID: <CAEPezq4Emc=D7zspWqLOq=80WGUjVdfT0xkqoJ1XQPXqaL3w6w@mail.gmail.com>
References: <CAEPezq43wKM1ivHAUu6pFoGqz9+nCJ1FT9xQV702S_BCQvropA@mail.gmail.com>
 <20170726084338.GH2235@orbyte.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
To: Phil Sutter <phil@nwl.cc>,
        Tyler Bautista <tylerbautista@gmail.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:38284 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751446AbdGZQrw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2017 12:47:52 -0400
Received: by mail-pg0-f53.google.com with SMTP id k190so21070649pgk.5
        for <netdev@vger.kernel.org>; Wed, 26 Jul 2017 09:47:51 -0700 (PDT)
In-Reply-To: <20170726084338.GH2235@orbyte.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Phil,

Thank you for taking my message. I have gotten a solution working so
feel free to ignore the rest of this email. By vanilla iproute2 do you
mean the latest package through the yum or apt repository? All I can
tell you is that in the example I gave the iproute2 package was the
latest one through the RHEL 7 yum repository. Otherwise I will need
clarification on what vanilla means. I attempted the above example
code on two other Ubuntu machines, one of which I can confirm is
Ubuntu 16.04 LTS. Unfortunately I am not at that machine right now so
I cannot give you the output. Both machines gave similar error
messages. The reason I emailed you via netdev was because the example
code I used was taken verbatim from the tc-pedit man page on my
machine. The man page also gave me email addresses to contact in case
an error was found with the man page, which is what I did. I did get
the code to work when using the latest version of iproute2, so I
assume the only practical solution is to manually install the latest
version of iproute2 or wait for the various distros of Linux to use
updated iproute2. I appreciate your help. Have a nice day.

Tyler Bautista

On Wed, Jul 26, 2017 at 1:43 AM, Phil Sutter <phil@nwl.cc> wrote:
> Hi Tyler,
>
> On Tue, Jul 25, 2017 at 08:33:40AM -0700, Tyler Bautista wrote:
>> To whom it may concern,
>> I recently attempted to use simple tc action pedit commands on the man
>> page and I ran into some errors. The following is some information
>> about my version of iproute and my machine:
>> ----------------------------
>> the following is my iproute package information
>>
>> Loaded plugins: fastestmirror, langpacks
>> iproute-3.10.0-74.el7.x86_64
>
> This mailing list is for upstream issues only. Can you reproduce the
> problem with vanilla iproute2?
>
> You are using RHEL7's iproute package, which has a number of known
> issues in pedit action:
>
> https://bugzilla.redhat.com/show_bug.cgi?id=1322406
>
> These are planned to be resolved for RHEL7.5, not sure when it will land
> in CentOS.
>
> Cheers, Phil
