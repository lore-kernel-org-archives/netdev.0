From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next V3 2/2] rtnl: Add support for netdev event
 attribute to link messages
Date: Thu, 27 Apr 2017 13:59:38 -0600
Message-ID: <760db30a-859a-a365-e0f3-69a4433ef9bf@cumulusnetworks.com>
References: <1492795881-11914-1-git-send-email-vyasevic@redhat.com>
 <1492795881-11914-3-git-send-email-vyasevic@redhat.com>
 <877efb54-2aef-4d1e-c0b4-2ce6aa6562df@cumulusnetworks.com>
 <7b5396ae-0cf3-2a1e-9c49-5d6f031adf58@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: roopa <roopa@cumulusnetworks.com>, Jiri Pirko <jiri@resnulli.us>
To: vyasevic@redhat.com, Vladislav Yasevich <vyasevich@gmail.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:35727 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935489AbdD0T7k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 15:59:40 -0400
Received: by mail-pf0-f174.google.com with SMTP id v14so36417474pfd.2
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2017 12:59:40 -0700 (PDT)
In-Reply-To: <7b5396ae-0cf3-2a1e-9c49-5d6f031adf58@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/27/17 1:43 PM, Vlad Yasevich wrote:
>> For example, NETDEV_CHANGEINFODATA is only for bonds though nothing
>> about the name suggests it is a bonding notification. This one was added
>> specifically to notify userspace (d4261e5650004), yet seems to happen
>> only during a changelink and that already generates a RTM_NEWLINK
>> message via do_setlink. Since the rtnetlink_event message does not
>> contain anything "NETDEV_CHANGEINFODATA" related what purpose does it
>> really serve besides duplicating netlink messages to userspace.
>>
> 
> I am not sure about this one, but if you have an app trying to monitor
> for this event, it can't really since there is no info in the netlink message.

I cc'ed Jiri on this thread hoping he would explain the intent.

I propose it gets removed.
