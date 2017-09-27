From: Berend De Schouwer <berend.de.schouwer@gmail.com>
Subject: Re: tg3 pxe weirdness
Date: Wed, 27 Sep 2017 12:05:17 +0200
Message-ID: <1506506717.18177.136.camel@gmail.com>
References: <CAMet4B6mZ8SyCT7W2j4OBEUDiy3ZupYKWXBFti0nXoxm51_6kg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Siva Reddy Kallam <siva.kallam@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36253 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751800AbdI0KFY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 06:05:24 -0400
Received: by mail-wm0-f66.google.com with SMTP id r136so11024971wmf.3
        for <netdev@vger.kernel.org>; Wed, 27 Sep 2017 03:05:24 -0700 (PDT)
In-Reply-To: <CAMet4B6mZ8SyCT7W2j4OBEUDiy3ZupYKWXBFti0nXoxm51_6kg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-09-25 at 15:11 +0530, Siva Reddy Kallam wrote:
> On Fri, Sep 22, 2017 at 9:04 PM, Berend De Schouwer
> <berend.de.schouwer@gmail.com> wrote:
> > On Fri, 2017-09-22 at 11:51 +0530, Siva Reddy Kallam wrote:
> > > 
> > > 
> > > Can you please share below details?
> > > 1) Model and Manufacturer of the system
> > > 2) Linux distro/kernel used?
> > 
> > 4.13.3 gets a little further, but after some more data is
> > transferred
> > the tg3 driver still crashes.  This is unfortunately before I've
> > got a
> > writeable filesystem.
> > 
> > The last line is:
> > tg3 0000:01:00.0: tg3_stop_block timed out, ofs=4c00 enable_bit=2
> > 
> > I've got some ideas to get the full dmesg.
> > 
> > As with the other kernels it works OK on 1Gbps, but not slower
> > switches.
> 
> I am suspecting with link aware mode, the clock speed could be slow
> and boot code does not
> complete within the expected time with lower link speeds. So,
> Providing a patch to override clock.
> Can you please try with attached debug patch and provide us the
> feedback with 100M link?
> If it solves this issue, we will work on proper changes.

This does work on 4.13.3 and PXE for me.

I've tested on 1 Gbps, 100 Mbps and 10 Mbps.  I've done some
preliminary testing (eg. large file copies.)
