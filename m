From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] net: ipv6: send unsolicited NA on admin up
Date: Thu, 13 Apr 2017 10:41:42 -0600
Message-ID: <14982ed9-77b0-0e61-e938-b73c4807e30f@cumulusnetworks.com>
References: <1492022944-18842-1-git-send-email-dsa@cumulusnetworks.com>
 <1492083944.2160091.943541576.3F765BD2@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:35508 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755127AbdDMQlp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2017 12:41:45 -0400
Received: by mail-pg0-f44.google.com with SMTP id 72so24541722pge.2
        for <netdev@vger.kernel.org>; Thu, 13 Apr 2017 09:41:45 -0700 (PDT)
In-Reply-To: <1492083944.2160091.943541576.3F765BD2@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/13/17 5:45 AM, Hannes Frederic Sowa wrote:
> 
> 
> On Wed, Apr 12, 2017, at 20:49, David Ahern wrote:
>> ndisc_notify is the ipv6 equivalent to arp_notify. When arp_notify is
>> set to 1, gratuitous arp requests are sent when the device is brought up.
>> The same is expected when ndisc_notify is set to 1 (per ndisc_notify in
>> Documentation/networking/ip-sysctl.txt). The NA is not sent on NETDEV_UP
>> event; add it.
>>
>> Fixes: 5cb04436eef6 ("ipv6: add knob to send unsolicited ND on link-layer
>> address change")
>> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> 
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> 
> In future we might be able to make this a bit more robust when DAD is
> happening at the same time.


agreed.
