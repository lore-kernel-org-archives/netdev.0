From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next] net: mpls: Add support for netconf
Date: Mon, 20 Feb 2017 16:18:27 +0100
Message-ID: <b25c8fd2-9b4b-5c27-b2bb-ffc44f08d5eb@6wind.com>
References: <1487381793-12234-1-git-send-email-dsa@cumulusnetworks.com>
 <9326b299-3969-7e0e-dba4-fae5682f0b24@brocade.com>
 <5c606636-64bb-a40b-c4bc-6292c5dc7678@cumulusnetworks.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: roopa@cumulusnetworks.com, ebiederm@xmission.com
To: David Ahern <dsa@cumulusnetworks.com>,
        Robert Shearman <rshearma@brocade.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f180.google.com ([209.85.128.180]:35367 "EHLO
        mail-wr0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752767AbdBTPSa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2017 10:18:30 -0500
Received: by mail-wr0-f180.google.com with SMTP id s27so19167276wrb.2
        for <netdev@vger.kernel.org>; Mon, 20 Feb 2017 07:18:29 -0800 (PST)
In-Reply-To: <5c606636-64bb-a40b-c4bc-6292c5dc7678@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 20/02/2017 à 15:53, David Ahern a écrit :
> On 2/20/17 3:01 AM, Robert Shearman wrote:
>> On 18/02/17 01:36, David Ahern wrote:
>>> Add netconf support to MPLS. Allows userpsace to learn and be notified
>>> of changes to 'input' enable setting per interface.
>>>
>>> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
>>> ---
>>>  include/uapi/linux/netconf.h   |   1 +
>>>  include/uapi/linux/rtnetlink.h |   2 +
>>>  net/mpls/af_mpls.c             | 212
>>> ++++++++++++++++++++++++++++++++++++++++-
>>>  net/mpls/internal.h            |   2 +-
>>>  4 files changed, 214 insertions(+), 3 deletions(-)
>>>
>>> diff --git a/include/uapi/linux/netconf.h b/include/uapi/linux/netconf.h
>>> index 45dfad509c4d..159d91c9c2a3 100644
>>> --- a/include/uapi/linux/netconf.h
>>> +++ b/include/uapi/linux/netconf.h
>>> @@ -16,6 +16,7 @@ enum {
>>>      NETCONFA_MC_FORWARDING,
>>>      NETCONFA_PROXY_NEIGH,
>>>      NETCONFA_IGNORE_ROUTES_WITH_LINKDOWN,
>>> +    NETCONFA_MPLS_INPUT_ENABLED,
>>
>> How about removing "MPLS_" the name? That way it would be usable by
>> other AFs too, e.g. for the disable_ipv6 sysctl. Perhaps "ENABLED" is
>> redundant as well.
> 
> 
> I could drop the MPLS to NETCONFA_INPUT_ENABLED; just NETCONFA_INPUT is
> not very descriptive.
> 
> disable_ipv6 has a completely different meaning, so re-use there does
> not seem appropriate.
To avoid confusion, the exact same name than the /proc entry is used.
NETCONFA_INPUT should be enough, because the family is already set to AF_MPLS.


Regards,
Nicolas
