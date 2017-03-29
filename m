From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next 0/7] netconf: Add support for RTM_DELNETCONF
Date: Wed, 29 Mar 2017 16:22:45 +0200
Message-ID: <99dfd055-8098-dd0f-bc1c-fb8d3d0c1190@6wind.com>
References: <1490736487-16020-1-git-send-email-dsa@cumulusnetworks.com>
 <20170328.223257.1804803147939889749.davem@davemloft.net>
 <3cc67fc9-4169-1b8d-39b4-0b7f408637a7@6wind.com>
 <295c0613-7ffd-5dfa-5ee3-aa5409445d92@cumulusnetworks.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f179.google.com ([209.85.128.179]:35891 "EHLO
        mail-wr0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751254AbdC2OWu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 10:22:50 -0400
Received: by mail-wr0-f179.google.com with SMTP id w11so17108355wrc.3
        for <netdev@vger.kernel.org>; Wed, 29 Mar 2017 07:22:48 -0700 (PDT)
In-Reply-To: <295c0613-7ffd-5dfa-5ee3-aa5409445d92@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 29/03/2017 à 16:13, David Ahern a écrit :
> On 3/29/17 3:36 AM, Nicolas Dichtel wrote:
>> Le 29/03/2017 à 07:32, David Miller a écrit :
>>> From: David Ahern <dsa@cumulusnetworks.com>
>>> Date: Tue, 28 Mar 2017 14:28:00 -0700
>>>
>>>> netconf notifications are sent as devices register but not when they
>>>> are deleted leaving userspace caches out of sync. Add support for
>>>> RTM_DELNETCONF to ipv4, ipv6 and mpls.
>> Not sure why those notifications are needed. When an interface is set down, ipv4
>> route deletion are not notified. Why is it needed for netconf?
>>
> 
> We carry a patch to send notifications for route deletes. In general, it
> makes management of libnl caches much easier when delete notifications
> are sent for each type. Without it, a link delete requires walking the
> other caches removing objects.
> 
David rejected this kind of patch several times, but maybe he changed his mind.
