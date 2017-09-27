From: Siva Reddy Kallam <siva.kallam@broadcom.com>
Subject: Re: tg3 pxe weirdness
Date: Wed, 27 Sep 2017 16:01:10 +0530
Message-ID: <CAMet4B4979pADZqK+6--jTFqUOF95X6FKF3Rhf9PKE-C9qOj4g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Berend De Schouwer <berend.de.schouwer@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f173.google.com ([209.85.220.173]:53532 "EHLO
        mail-qk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751521AbdI0KbL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 06:31:11 -0400
Received: by mail-qk0-f173.google.com with SMTP id w63so2053070qkd.10
        for <netdev@vger.kernel.org>; Wed, 27 Sep 2017 03:31:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 27, 2017 at 3:35 PM, Berend De Schouwer
<berend.de.schouwer@gmail.com> wrote:
> On Mon, 2017-09-25 at 15:11 +0530, Siva Reddy Kallam wrote:
>> On Fri, Sep 22, 2017 at 9:04 PM, Berend De Schouwer
>> <berend.de.schouwer@gmail.com> wrote:
>> > On Fri, 2017-09-22 at 11:51 +0530, Siva Reddy Kallam wrote:
>> > >
>> > >
>> > > Can you please share below details?
>> > > 1) Model and Manufacturer of the system
>> > > 2) Linux distro/kernel used?
>> >
>> > 4.13.3 gets a little further, but after some more data is
>> > transferred
>> > the tg3 driver still crashes.  This is unfortunately before I've
>> > got a
>> > writeable filesystem.
>> >
>> > The last line is:
>> > tg3 0000:01:00.0: tg3_stop_block timed out, ofs=4c00 enable_bit=2
>> >
>> > I've got some ideas to get the full dmesg.
>> >
>> > As with the other kernels it works OK on 1Gbps, but not slower
>> > switches.
>>
>> I am suspecting with link aware mode, the clock speed could be slow
>> and boot code does not
>> complete within the expected time with lower link speeds. So,
>> Providing a patch to override clock.
>> Can you please try with attached debug patch and provide us the
>> feedback with 100M link?
>> If it solves this issue, we will work on proper changes.
>
> This does work on 4.13.3 and PXE for me.
>
> I've tested on 1 Gbps, 100 Mbps and 10 Mbps.  I've done some
> preliminary testing (eg. large file copies.)

Good. We will work on required changes and upstream proper patch after
sanity test with multiple speeds.
