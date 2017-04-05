From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [iproute2 net-next v2 0/3] ip netconf improvements
Date: Wed, 5 Apr 2017 08:18:12 -0400
Message-ID: <2e95cd50-8619-0a51-e22f-b8ced94f01d4@cumulusnetworks.com>
References: <1490323882-11609-1-git-send-email-dsa@cumulusnetworks.com>
 <431908e0-27b0-730d-0c01-671702f30d71@cumulusnetworks.com>
 <20170404143912.7ecae6ba@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nicolas.dichtel@6wind.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:34159 "EHLO
        mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754657AbdDEMSO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Apr 2017 08:18:14 -0400
Received: by mail-io0-f169.google.com with SMTP id b140so8148890iof.1
        for <netdev@vger.kernel.org>; Wed, 05 Apr 2017 05:18:13 -0700 (PDT)
In-Reply-To: <20170404143912.7ecae6ba@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/4/17 5:39 PM, Stephen Hemminger wrote:
> On Tue, 4 Apr 2017 17:07:31 -0400
> David Ahern <dsa@cumulusnetworks.com> wrote:
> 
>> On 3/23/17 10:51 PM, David Ahern wrote:
>>> Currently, ip netconf only shows data for ipv4 and ipv6 for dumps
>>> and just ipv4 for device requests. Improve the user experience by
>>> using the new kernel patch to dump all address families that have
>>> registered. For example, if mpls_router module is loaded then mpls
>>> values are displayed along with ipv4 and ipv6.
>>>
>>> If the new feature is not supported (new iproute2 on older kernel)
>>> the kernel returns the nlmsg error EOPNOTSUPP which can be trapped
>>> and fallback to existing behavior.
>>>
>>> v2
>>> - fixed index conversion in patch 3 per nicholas' comment
>>>
>>> David Ahern (3):
>>>   netlink: Add flag to suppress print of nlmsg error
>>>   ip netconf: Show all address families by default in dumps
>>>   ip netconf: show all families on dev request
>>>
>>>  include/libnetlink.h |  1 +
>>>  ip/ipnetconf.c       | 36 +++++++++++++++++++++++++-----------
>>>  lib/libnetlink.c     |  3 ++-
>>>  3 files changed, 28 insertions(+), 12 deletions(-)
>>>   
>>
>> Hi Stephen: any comments? are you ok with this change?
> 
> I was holding off until all the upstream commits went through. Other than
> that fine.
> 

I'm not aware of any kernel commits that not in net-next, so I think we
good to go on the kernel side.
