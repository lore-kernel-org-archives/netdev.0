From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH RFC net-next 0/6] net: reducing memory footprint of
 network devices
Date: Tue, 9 May 2017 08:42:05 -0700
Message-ID: <d8bffd7a-0c2f-7815-4483-e096b56f2975@gmail.com>
References: <20170506160734.47084-1-dsahern@gmail.com>
 <89333e30-0a5d-0f05-4d14-d75dc157d6ba@gmail.com>
 <1be60a5e-da39-5657-b1fe-c91266800046@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com
To: nicolas.dichtel@6wind.com, Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35228 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751705AbdEIPmI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 9 May 2017 11:42:08 -0400
Received: by mail-pf0-f195.google.com with SMTP id u26so470642pfd.2
        for <netdev@vger.kernel.org>; Tue, 09 May 2017 08:42:08 -0700 (PDT)
In-Reply-To: <1be60a5e-da39-5657-b1fe-c91266800046@6wind.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/9/17 2:50 AM, Nicolas Dichtel wrote:
> Your initial patch tried to make those interfaces transparent, this is not the
> case anymore here. It would probably be useful to be able to filter those
> interfaces in the kernel during a dump.

The earlier email was for hidden devices; the intent there is to hide
certain devices (e.g., switch control netdevs) from user dumps by default.

Adding an attribute at create time such as IFF_INVISIBLE for such
devices would be a follow on to this set - but leveraging the same
sysctl and sysfs bypasses.
