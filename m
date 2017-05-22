From: Arend van Spriel <arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH 1/1] dt-binding: net: wireless: fix node name in the
 BCM43xx example
Date: Mon, 22 May 2017 11:37:56 +0200
Message-ID: <9e7ee577-d01e-150c-1785-52d8b9024775@broadcom.com>
References: <20170515201356.26384-1-martin.blumenstingl@googlemail.com>
 <20170515201356.26384-2-martin.blumenstingl@googlemail.com>
 <8155d0f1-aed3-fc47-4524-635067f9ee7b@broadcom.com>
 <CAFBinCBeijYMJ+hTajCA-2D7S1aH6E2mc_gm-2cAqKt87XVNkg@mail.gmail.com>
 <11675313-d92f-e562-0fd5-21339b5aa599@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: =?UTF-8?Q?Andreas_F=c3=a4rber?= <afaerber-l3A5Bk7waGM@public.gmane.org>,
        Martin Blumenstingl <martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <11675313-d92f-e562-0fd5-21339b5aa599-l3A5Bk7waGM@public.gmane.org>
Content-Language: en-GB
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 5/21/2017 4:19 PM, Andreas Färber wrote:
> Hi,
> 
> Am 16.05.2017 um 21:56 schrieb Martin Blumenstingl:
>> On Tue, May 16, 2017 at 12:05 AM, Arend Van Spriel
>> <arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org> wrote:
>>> On 15-5-2017 22:13, Martin Blumenstingl wrote:
>>>> The example in the BCM43xx documentation uses "brcmf" as node name.
>>>> However, wireless devices should be named "wifi" instead. Fix this to
>>>
>>> Since when is that a rule. I never got the memo and the DTC did not ever
>>> complain to me about the naming.
> 
> How do you expect it to? Maintain a blacklist of every device model
> someone might use, including all typo variations?

Not really why I was asking it. Just saying the node name is trivial as 
I don't think there is different kernel behaviour depending on the node 
name.

>> That being said I do not really care
>>> and I suppose it is for the sake of consistency only.
>> I'm not sure if it's actually a rule or (as you already noted) just
>> for consistency. back when I added devicetree support to ath9k Rob
>> pointed out that the node should be named "wifi" (instead of "ath9k"),
>> see [0]
> 
> The general rule is that the node name should be the type of the device,
> not duplicate its compatible string.
> 
> For consistency Rob was asking we use "wifi" as node name.

Fine with that. Not sure how long ago it was that I added this binding, 
but DT folks were involved back than. I never looked back so I should 
not be surprised with new consistency rules. I was just curious about 
the story behind it.

Thanks,
Arend
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
