From: Berend De Schouwer <berend.de.schouwer@gmail.com>
Subject: Re: tg3 pxe weirdness
Date: Fri, 22 Sep 2017 17:34:05 +0200
Message-ID: <1506094445.18177.117.camel@gmail.com>
References: <CAMet4B4Jdgjs42KAWQ4HJr1t_Grn1_+Hv8sipeLb_tvZ_SFrMw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Siva Reddy Kallam <siva.kallam@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:45571 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752020AbdIVPeL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2017 11:34:11 -0400
Received: by mail-wm0-f51.google.com with SMTP id q124so5008923wmb.0
        for <netdev@vger.kernel.org>; Fri, 22 Sep 2017 08:34:11 -0700 (PDT)
In-Reply-To: <CAMet4B4Jdgjs42KAWQ4HJr1t_Grn1_+Hv8sipeLb_tvZ_SFrMw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-09-22 at 11:51 +0530, Siva Reddy Kallam wrote:
> 
> 
> Can you please share below details?
> 1) Model and Manufacturer of the system
> 2) Linux distro/kernel used?

4.13.3 gets a little further, but after some more data is transferred
the tg3 driver still crashes.  This is unfortunately before I've got a
writeable filesystem.

The last line is:
tg3 0000:01:00.0: tg3_stop_block timed out, ofs=4c00 enable_bit=2

I've got some ideas to get the full dmesg.

As with the other kernels it works OK on 1Gbps, but not slower
switches.
