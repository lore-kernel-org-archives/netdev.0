From: Stefan Schmidt <stefan@osg.samsung.com>
Subject: Re: [PATCH] ieee802154-atusb: Delete an unnecessary check before the
 function call "kfree_skb"
Date: Thu, 10 Dec 2015 11:14:43 +0100
Message-ID: <56695093.8080605@osg.samsung.com>
References: <5307CAA2.8060406@users.sourceforge.net>
 <alpine.DEB.2.02.1402212321410.2043@localhost6.localdomain6>
 <530A086E.8010901@users.sourceforge.net>
 <alpine.DEB.2.02.1402231635510.1985@localhost6.localdomain6>
 <530A72AA.3000601@users.sourceforge.net>
 <alpine.DEB.2.02.1402240658210.2090@localhost6.localdomain6>
 <530B5FB6.6010207@users.sourceforge.net>
 <alpine.DEB.2.10.1402241710370.2074@hadrien>
 <530C5E18.1020800@users.sourceforge.net>
 <alpine.DEB.2.10.1402251014170.2080@hadrien>
 <530CD2C4.4050903@users.sourceforge.net>
 <alpine.DEB.2.10.1402251840450.7035@hadrien>
 <530CF8FF.8080600@users.sourceforge.net>
 <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6>
 <530DD06F.4090703@users.sourceforge.net>
 <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6>
 <5317A59D.4@users.sourceforge.net> <564B5327.4010307@osg.samsung.com>
 <564B5344.1090200@osg.samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: Alexander Aring <alex.aring@gmail.com>, linux-wpan@vger.kernel.org,
	netdev@vger.kernel.org, Marcel Holtmann <marcel@holtmann.org>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <564B5344.1090200@osg.samsung.com>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Marcel,

On 17/11/15 17:18, Stefan Schmidt wrote:
> Hello.
>
> On 17/11/15 17:17, Stefan Schmidt wrote:
>> From: Markus Elfring <elfring@users.sourceforge.net>
>> Date: Mon, 16 Nov 2015 13:50:23 +0100
>>
>> The kfree_skb() function tests whether its argument is NULL and then
>> returns immediately. Thus the test around the call is not needed.
>>
>> This issue was detected by using the Coccinelle software.
>>
>> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
>> ---
>>  drivers/net/ieee802154/atusb.c | 3 +--
>>  1 file changed, 1 insertion(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/ieee802154/atusb.c 
>> b/drivers/net/ieee802154/atusb.c
>> index 199a94a..b1cd865 100644
>> --- a/drivers/net/ieee802154/atusb.c
>> +++ b/drivers/net/ieee802154/atusb.c
>> @@ -310,8 +310,7 @@ static void atusb_free_urbs(struct atusb *atusb)
>>          urb = usb_get_from_anchor(&atusb->idle_urbs);
>>          if (!urb)
>>              break;
>> -        if (urb->context)
>> -            kfree_skb(urb->context);
>> +        kfree_skb(urb->context);
>>          usb_free_urb(urb);
>>      }
>>  }
>
> Acked-by: Stefan Schmidt <stefan@osg.samsung.com>


You got the original patch and my ACK on this one or would you prefer me 
to resend it again?

regards
Stefan Schmidt
