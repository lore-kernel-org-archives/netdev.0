From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH V5 1/2] rtnl: Add support for netdev event to link
 messages
Date: Fri, 26 May 2017 14:04:00 -0600
Message-ID: <5d8f7bc5-bf2d-19f3-a27a-5a56f1273a6f@gmail.com>
References: <1495726316-27626-1-git-send-email-vyasevic@redhat.com>
 <1495726316-27626-2-git-send-email-vyasevic@redhat.com>
 <0d252e48-cbd0-5d5d-1e30-9c7e79ea9d01@gmail.com>
 <9e56d973-450e-7dfe-5a33-23922d449cd5@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, jiri@resnulli.us, vfalico@gmail.com,
        andy@greyhouse.net
To: vyasevic@redhat.com, Vladislav Yasevich <vyasevich@gmail.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33416 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934332AbdEZUED (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 16:04:03 -0400
Received: by mail-pf0-f196.google.com with SMTP id f27so5050050pfe.0
        for <netdev@vger.kernel.org>; Fri, 26 May 2017 13:04:03 -0700 (PDT)
In-Reply-To: <9e56d973-450e-7dfe-5a33-23922d449cd5@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/26/17 2:01 PM, Vlad Yasevich wrote:
>> Also, generically the IFLA_EVENT attribute should be considered
>> independent of NETDEV_ events.
>>
>> For example, userspace should be notified if the speed / duplex for a
>> device changes, so we could have another one of these -- e.g.,
>> IFLA_EVENT_SPEED -- that does not correlate to NETDEV_SPEED since
>> nothing internal to the network stack cares about speed changes, or
>> perhaps more generically it is IFLA_EVENT_LINK_SETTING.
>>
> 
> Ok.  We could do a translation between netdev event and IFLA_EVENT attribute value
> earlier (say in rtnetlink_event) and pass that along.  This would allow calls
> from other places, assuming proper IFLA_EVENT attribute value and translation
> is defined.
> 
> Would that address your concerns?

yes. that code re-factoring can be done when it is needed.
