From: Warren Turkal <wt@penguintechs.org>
Subject: dummy ethernet devices and sysfs
Date: Wed, 13 Jan 2016 11:58:01 -0800
Message-ID: <CAB_jBhhyNLeYSuOQUXPTtU3LaVdjXtD=jS0kuvMckDjyOz1Xzg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:33427 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752624AbcAMT6W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jan 2016 14:58:22 -0500
Received: by mail-ig0-f181.google.com with SMTP id z14so176533082igp.0
        for <netdev@vger.kernel.org>; Wed, 13 Jan 2016 11:58:21 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I was looking through sysfs today, and something interesting jumped
out at me after I loaded the dummy module.

This directory exists: /sys/class/net/wlp2s0/device/

This directory does not: /sys/class/net/dummy0/device/

I can find the module that is providing the wlp2s0 device with the following:
$ ls /sys/class/net/wlp2s0/device/driver/module/drivers/
pci:iwlwifi

Shouldn't dummy have something similar so that one can figure out
which module is providing the dummy0 device?

FWIW, I am running the latest Ubuntu 15.10 kernel (4.2.0-23-generic).

Thanks,
wt
