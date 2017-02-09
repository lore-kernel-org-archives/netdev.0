From: "pupilla@libero.it" <pupilla@libero.it>
Subject: R: Re: [PATCH net] lwtunnel: valid encap attr check should return 0
 when lwtunnel is disabled
Date: Thu, 9 Feb 2017 09:48:58 +0100 (CET)
Message-ID: <533381532.379531486630138912.JavaMail.httpd@webmail-35.iol.local>
Reply-To: "pupilla@libero.it" <pupilla@libero.it>
Mime-Version: 1.0
Content-Type: text/plain;charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>, <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-17.italiaonline.it ([212.48.25.145]:39926 "EHLO libero.it"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751777AbdBIItY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Feb 2017 03:49:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:

>Data: 8-feb-2017 18.55
>A: <dsa@cumulusnetworks.com>
>Cc: <netdev@vger.kernel.org>, <pupilla@libero.it>
>Ogg: Re: [PATCH net] lwtunnel: valid encap attr check should return 0 when 
lwtunnel is disabled
>
>From: David Ahern <dsa@cumulusnetworks.com>
>Date: Wed,  8 Feb 2017 09:29:00 -0800
>
>> An error was reported upgrading to 4.9.8:
>>     root@Typhoon:~# ip route add default table 210 nexthop dev eth0 via 
10.68.64.1
>>     weight 1 nexthop dev eth0 via 10.68.64.2 weight 1
>>     RTNETLINK answers: Operation not supported
>> 
>> The problem occurs when CONFIG_LWTUNNEL is not enabled and a multipath
>> route is submitted.
>> 
>> The point of lwtunnel_valid_encap_type_attr is catch modules that
>> need to be loaded before any references are taken with rntl held. With
>> CONFIG_LWTUNNEL disabled, there will be no modules to load so the
>> lwtunnel_valid_encap_type_attr stub should just return 0.
>> 
>> Fixes: 9ed59592e3e3 ("lwtunnel: fix autoload of lwt modules")
>> Reported-by: pupilla@libero.it
>> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
>
>Applied and queued up for -stable, thanks for fixing this so quickly David.

Thanks everybody. I have applied the patch to linux-4.9.8 and all is fine.

Thanks again.

Marco
