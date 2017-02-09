From: Murali Karicheri <m-karicheri2@ti.com>
Subject: Linux HSR driver question
Date: Thu, 9 Feb 2017 15:32:53 -0500
Message-ID: <589CD1F5.1060104@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: "arvid.brodin@alten.se >> Arvid Brodin" <arvid.brodin@alten.se>,
        "open list:TI NETCP ETHERNET DRIVER" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fllnx210.ext.ti.com ([198.47.19.17]:17652 "EHLO
        fllnx210.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754086AbdBIU5r (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 15:57:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Arvid,

While I work to add PRP support to the existing Linux HSR driver, I came across
a piece of code related to prune node function. The hsr_device.c adds the 
prune timer in hsr_dev_finalize() by calling

add_timer(&hsr->prune_timer);

But it is never restarted in hsr_prune_nodes(). Is that intentional or a bug?
I tried adding add_timer(&hsr->prune_timer) at the end of  hsr_prune_nodes(),
but then a iperf test stops with no traffic across the hsr interface and it
never recovers. I have to delete the interface and create it again to recover.
Is that the reason, it is currently disabled?

-- 
Murali Karicheri
Linux Kernel, Keystone
