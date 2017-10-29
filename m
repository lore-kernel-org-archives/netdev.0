From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: can: Use common error handling code in vxcan_newlink()
Date: Sun, 29 Oct 2017 11:51:48 +0100
Message-ID: <a76159d3-650e-5c2e-0f4a-dca394350473@hartkopp.net>
References: <2e600d9a-faec-dd39-08f0-5a7fb260d7ca@users.sourceforge.net>
 <2ab5d794-7a5c-9036-835c-67cfcc541795@hartkopp.net>
 <d3bdd3c0-5a03-dd59-07ca-94b126c67f75@users.sourceforge.net>
 <264b3c2b-8354-5769-639c-ac8d2fcbe630@hartkopp.net>
 <5a76bb36-4ae0-eca2-ae34-69c2bfddb634@users.sourceforge.net>
 <4d612668-5423-4ce3-a4f5-ee394d7ddd21@hartkopp.net>
 <19ca5f23-fbb0-aaae-bff5-d634af66c264@users.sourceforge.net>
 <9d9b724b-229a-acab-54f8-6c45dda96f44@hartkopp.net>
 <8761e059-d33c-a157-4b2f-f01dbdf2a91e@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Marc Kleine-Budde <mkl@pengutronix.de>,
        Wolfgang Grandegger <wg@grandegger.com>,
        LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: SF Markus Elfring <elfring@users.sourceforge.net>,
        linux-can@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.162]:25187 "EHLO
        mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751147AbdJ2KwA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Oct 2017 06:52:00 -0400
In-Reply-To: <8761e059-d33c-a157-4b2f-f01dbdf2a91e@users.sourceforge.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Markus,

this discussion went far beyond the original posted patch for vxcan.c

I would suggest you post your idea of the simplified error handling flow 
in vxcan.c just on linux-can ML (which is the right mailing list for CAN 
related stuff).

Thanks,
Oliver

On 10/28/2017 10:13 PM, SF Markus Elfring wrote:
>>> Are you interested in related adjustments for a bigger code base?
>>
>> No. Definitely not.
> 
> You might have noticed that I am proposing similar changes already
> for other software modules.   ;-)
> 
> 
>> If you aim for the the deletion of “ < 0” for all rtnl_configure_link() users
>> you would need to do this consistently.
> 
> How do you see the software situation around a function
> like “register_netdevice”?
> 
> Regards,
> Markus
> 
