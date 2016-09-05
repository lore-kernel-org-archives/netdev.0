From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [RFC 2/9] ipv6: sr: add code base for control plane support of
 SR-IPv6
Date: Mon, 5 Sep 2016 12:05:57 +0200
Message-ID: <ab7ef74f-294b-af2b-cbd4-d500fc0423ef@6wind.com>
References: <1472226767-9904-1-git-send-email-david.lebrun@uclouvain.be>
 <1472226767-9904-3-git-send-email-david.lebrun@uclouvain.be>
 <57C4554F.9000905@cumulusnetworks.com> <57C82B43.80100@uclouvain.be>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: David Lebrun <david.lebrun@uclouvain.be>,
        Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:37108 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753498AbcIEKGA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Sep 2016 06:06:00 -0400
Received: by mail-wm0-f43.google.com with SMTP id w12so32059139wmf.0
        for <netdev@vger.kernel.org>; Mon, 05 Sep 2016 03:06:00 -0700 (PDT)
In-Reply-To: <57C82B43.80100@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 01/09/2016 à 15:21, David Lebrun a écrit :
> On 08/29/2016 05:31 PM, Roopa Prabhu wrote:
>> This looks fine. But, i am just trying to see if this can be rtnetlink.
>> Have you considered it already ?.
>> We would like to keep the API consistent or abstracted to accommodate SR-MPLS in the
>> future too. so, any abstraction there will help.
>>
>> what is your control-plane software using this ?
>> quagga or any-other routing daemon ?
>>
>> Thanks,
>> Roopa
>>
> 
> rtnetlink is used for the routing part through the lwtunnels. In this
> specific patch, the API is intended to configure namespace-wide
> parameters such as a map of hmackeyid -> hashfn,secret, without
> connection to particular routes. I agree that the tunsrc parameter could
> be provided through rtnetlink, but the hmac data cannot (which by the
> way does not exist for SR-MPLS).
But it's closely related to routes. You can add a new family RTM_foo. It will be
easier to implement userspace part (only one netlink family is involved).


Regards,
Nicolas
