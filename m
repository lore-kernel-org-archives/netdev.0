From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next V3 2/2] rtnl: Add support for netdev event
 attribute to link messages
Date: Fri, 28 Apr 2017 18:38:04 +0200
Message-ID: <20170428163804.GH1886@nanopsycho.orion>
References: <1492795881-11914-1-git-send-email-vyasevic@redhat.com>
 <1492795881-11914-3-git-send-email-vyasevic@redhat.com>
 <877efb54-2aef-4d1e-c0b4-2ce6aa6562df@cumulusnetworks.com>
 <7b5396ae-0cf3-2a1e-9c49-5d6f031adf58@redhat.com>
 <760db30a-859a-a365-e0f3-69a4433ef9bf@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vyasevic@redhat.com, Vladislav Yasevich <vyasevich@gmail.com>,
        netdev@vger.kernel.org, roopa <roopa@cumulusnetworks.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34310 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756811AbdD1QiJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 12:38:09 -0400
Received: by mail-wm0-f65.google.com with SMTP id z129so12022366wmb.1
        for <netdev@vger.kernel.org>; Fri, 28 Apr 2017 09:38:07 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <760db30a-859a-a365-e0f3-69a4433ef9bf@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Apr 27, 2017 at 09:59:38PM CEST, dsa@cumulusnetworks.com wrote:
>On 4/27/17 1:43 PM, Vlad Yasevich wrote:
>>> For example, NETDEV_CHANGEINFODATA is only for bonds though nothing
>>> about the name suggests it is a bonding notification. This one was added
>>> specifically to notify userspace (d4261e5650004), yet seems to happen
>>> only during a changelink and that already generates a RTM_NEWLINK
>>> message via do_setlink. Since the rtnetlink_event message does not
>>> contain anything "NETDEV_CHANGEINFODATA" related what purpose does it
>>> really serve besides duplicating netlink messages to userspace.
>>>
>> 
>> I am not sure about this one, but if you have an app trying to monitor
>> for this event, it can't really since there is no info in the netlink message.
>
>I cc'ed Jiri on this thread hoping he would explain the intent.
>
>I propose it gets removed.

Hmm, I don't really recall. But looking at it now, I agree it is
redundant.
