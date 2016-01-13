From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: dummy ethernet devices and sysfs
Date: Wed, 13 Jan 2016 12:16:09 -0800
Message-ID: <20160113121609.139af5a2@xeon-e3>
References: <CAB_jBhhyNLeYSuOQUXPTtU3LaVdjXtD=jS0kuvMckDjyOz1Xzg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Warren Turkal <wt@penguintechs.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34543 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757302AbcAMUQA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jan 2016 15:16:00 -0500
Received: by mail-pa0-f48.google.com with SMTP id uo6so347761503pac.1
        for <netdev@vger.kernel.org>; Wed, 13 Jan 2016 12:16:00 -0800 (PST)
In-Reply-To: <CAB_jBhhyNLeYSuOQUXPTtU3LaVdjXtD=jS0kuvMckDjyOz1Xzg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 13 Jan 2016 11:58:01 -0800
Warren Turkal <wt@penguintechs.org> wrote:

> Hi,
> 
> I was looking through sysfs today, and something interesting jumped
> out at me after I loaded the dummy module.
> 
> This directory exists: /sys/class/net/wlp2s0/device/
> 
> This directory does not: /sys/class/net/dummy0/device/
> 
> I can find the module that is providing the wlp2s0 device with the following:
> $ ls /sys/class/net/wlp2s0/device/driver/module/drivers/
> pci:iwlwifi
> 
> Shouldn't dummy have something similar so that one can figure out
> which module is providing the dummy0 device?
> 
> FWIW, I am running the latest Ubuntu 15.10 kernel (4.2.0-23-generic).
> 
> Thanks,
> wt

If you look carefully at the /sys/class/net/wlp2s0/device/ you will
see it is a symlink to the underlying /sys directory for the hardware (PCI)
device.  Since dummy (and other virtual interfaces) have no hardware,
there is no symlink.
