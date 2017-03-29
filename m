From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next 0/7] netconf: Add support for RTM_DELNETCONF
Date: Wed, 29 Mar 2017 11:36:19 +0200
Message-ID: <3cc67fc9-4169-1b8d-39b4-0b7f408637a7@6wind.com>
References: <1490736487-16020-1-git-send-email-dsa@cumulusnetworks.com>
 <20170328.223257.1804803147939889749.davem@davemloft.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:37202 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754593AbdC2JgY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 05:36:24 -0400
Received: by mail-wm0-f48.google.com with SMTP id x124so19819897wmf.0
        for <netdev@vger.kernel.org>; Wed, 29 Mar 2017 02:36:23 -0700 (PDT)
In-Reply-To: <20170328.223257.1804803147939889749.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 29/03/2017 à 07:32, David Miller a écrit :
> From: David Ahern <dsa@cumulusnetworks.com>
> Date: Tue, 28 Mar 2017 14:28:00 -0700
> 
>> netconf notifications are sent as devices register but not when they
>> are deleted leaving userspace caches out of sync. Add support for
>> RTM_DELNETCONF to ipv4, ipv6 and mpls.
Not sure why those notifications are needed. When an interface is set down, ipv4
route deletion are not notified. Why is it needed for netconf?

>>
>> MPLS is missing RTM_NEWNETCONF as devices are created, so add it as well.
> 
> Series applied, thanks.
> 
