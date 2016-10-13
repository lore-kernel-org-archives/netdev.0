From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next RFC 0/6] Add support for offloading
 packet-sampling
Date: Thu, 13 Oct 2016 08:30:19 -0400
Message-ID: <2cc65dfa-de32-2e31-5f03-80e8f0d2586f@mojatatu.com>
References: <1476276069-5315-1-git-send-email-jiri@resnulli.us>
 <57FF37F5.4070100@cumulusnetworks.com>
 <20161013084857.GC1816@nanopsycho.orion>
 <64872c5b-8cbc-edd8-00aa-afc87a7cfa4a@mojatatu.com>
 <20161013121022.GD1816@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>, netdev@vger.kernel.org,
        davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        geert+renesas@glider.be, stephen@networkplumber.org,
        xiyou.wangcong@gmail.com, linux@roeck-us.net
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:35406 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755641AbcJMMpt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 08:45:49 -0400
Received: by mail-it0-f67.google.com with SMTP id l13so5761599itl.2
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2016 05:45:49 -0700 (PDT)
In-Reply-To: <20161013121022.GD1816@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-10-13 08:10 AM, Jiri Pirko wrote:
> Thu, Oct 13, 2016 at 01:49:07PM CEST, jhs@mojatatu.com wrote:
>> On 16-10-13 04:48 AM, Jiri Pirko wrote:

[..]
>> Roopa, did you mean eth1 as the new device or did you mean just in
>> general config requiring a device to be specified or did you mean a new
>> cpu netdev being needed? I couldnt tell from the patch.
>
> You just have to have some netdev to use to funnel the IFE headered
> sample skbs to userspace. A dummy or a tap.
>

I see.
So with nflog you get basically a backend using a netlink socket
but in your case you will redirect to tuntap for the case of local
sflow but some other device for remote? I am assuming using dummy
would require a packet socket as means of retrieving the data.
If you take the structuring of the metadata that nflog uses it should
be easy to transpose.
To Roopa's point, however: Would it not make sense to support nflog
(in addition?).

cheers,
jamal
