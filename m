From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC net-next 4/6] net: Do not intialize kobject for
 lightweight netdevs
Date: Mon, 8 May 2017 10:26:59 -0700
Message-ID: <cc6c7118-95f0-5252-4962-b4376b4bf61d@gmail.com>
References: <20170506160734.47084-1-dsahern@gmail.com>
 <20170506160734.47084-5-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, nicolas.dichtel@6wind.com
To: David Ahern <dsahern@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:32983 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754638AbdEHR1D (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 8 May 2017 13:27:03 -0400
Received: by mail-qk0-f193.google.com with SMTP id o85so11081396qkh.0
        for <netdev@vger.kernel.org>; Mon, 08 May 2017 10:27:02 -0700 (PDT)
In-Reply-To: <20170506160734.47084-5-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/06/2017 09:07 AM, David Ahern wrote:
> Lightweight netdevices are not added to sysfs; bypass kobject
> initialization.

I was wondering if we actually needed a flag to tell: this is a
lightweight device, but still let it show up in /sys. All use cases that
I have in mind (getting the physical port name etc. etc) can be done via
netlink which is not restricted even with LWT devices, so this sounds
reasonable. In case we need to revisit that, we can always add more
flags to control the lightweight devices creation and how this
percolates through the networking stack.

Thanks!
-- 
Florian
