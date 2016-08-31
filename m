From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [RFC 2/9] ipv6: sr: add code base for control plane support of
 SR-IPv6
Date: Wed, 31 Aug 2016 16:57:41 +0200
Message-ID: <e91f9810-3c59-a616-d926-d98d79cfe1e3@6wind.com>
References: <1472226767-9904-1-git-send-email-david.lebrun@uclouvain.be>
 <1472226767-9904-3-git-send-email-david.lebrun@uclouvain.be>
 <57C4554F.9000905@cumulusnetworks.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Roopa Prabhu <roopa@cumulusnetworks.com>,
        David Lebrun <david.lebrun@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:38094 "EHLO
        mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935602AbcHaO57 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2016 10:57:59 -0400
Received: by mail-wm0-f42.google.com with SMTP id 1so45912117wmz.1
        for <netdev@vger.kernel.org>; Wed, 31 Aug 2016 07:57:43 -0700 (PDT)
In-Reply-To: <57C4554F.9000905@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 29/08/2016 à 17:31, Roopa Prabhu a écrit :
> On 8/26/16, 8:52 AM, David Lebrun wrote:
>> This patch adds the necessary hooks and structures to provide support
>> for SR-IPv6 control plane, essentially the Generic Netlink commands
>> that will be used for userspace control over the Segment Routing
>> kernel structures.
>>
>> The genetlink commands provide control over two different structures:
>> tunnel source and HMAC data. The tunnel source is the source address
>> that will be used by default when encapsulating packets into an
>> outer IPv6 header + SRH. If the tunnel source is set to :: then an
>> address of the outgoing interface will be selected as the source.
>>
>> The HMAC commands currently just return ENOTSUPP and will be implemented
>> in a future patch.
>>
>> Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
>>
> This looks fine. But, i am just trying to see if this can be rtnetlink.
I agree with Roopa, why not using rtnl?
