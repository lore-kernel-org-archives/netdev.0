From: Martin Blumenstingl <martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Subject: Re: [PATCH 1/1] dt-binding: net: wireless: fix node name in the
 BCM43xx example
Date: Tue, 16 May 2017 21:56:38 +0200
Message-ID: <CAFBinCBeijYMJ+hTajCA-2D7S1aH6E2mc_gm-2cAqKt87XVNkg@mail.gmail.com>
References: <20170515201356.26384-1-martin.blumenstingl@googlemail.com>
 <20170515201356.26384-2-martin.blumenstingl@googlemail.com> <8155d0f1-aed3-fc47-4524-635067f9ee7b@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Arend Van Spriel <arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <8155d0f1-aed3-fc47-4524-635067f9ee7b-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Arend,

On Tue, May 16, 2017 at 12:05 AM, Arend Van Spriel
<arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org> wrote:
> On 15-5-2017 22:13, Martin Blumenstingl wrote:
>> The example in the BCM43xx documentation uses "brcmf" as node name.
>> However, wireless devices should be named "wifi" instead. Fix this to
>
> Hi Martin,
>
> Since when is that a rule. I never got the memo and the DTC did not ever
> complain to me about the naming. That being said I do not really care
> and I suppose it is for the sake of consistency only.
I'm not sure if it's actually a rule or (as you already noted) just
for consistency. back when I added devicetree support to ath9k Rob
pointed out that the node should be named "wifi" (instead of "ath9k"),
see [0]

>> make sure that .dts authors can simply use the documentation as
>> reference (or simply copy the node from the documentation and then
>> adjust only the board specific bits).
>
> Please feel free to add my...
>
> Acked-by: Arend van Spriel <arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
thank you!

@Rob: maybe you can ACK this as well if you're fine with this patch?

>> Signed-off-by: Martin Blumenstingl <martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
>> ---
>>  Documentation/devicetree/bindings/net/wireless/brcm,bcm43xx-fmac.txt | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/Documentation/devicetree/bindings/net/wireless/brcm,bcm43xx-fmac.txt b/Documentation/devicetree/bindings/net/wireless/brcm,bcm43xx-fmac.txt
>> index 5dbf169cd81c..590f622188de 100644
>> --- a/Documentation/devicetree/bindings/net/wireless/brcm,bcm43xx-fmac.txt
>> +++ b/Documentation/devicetree/bindings/net/wireless/brcm,bcm43xx-fmac.txt
>> @@ -31,7 +31,7 @@ mmc3: mmc@01c12000 {
>>       non-removable;
>>       status = "okay";
>>
>> -     brcmf: bcrmf@1 {
>> +     brcmf: wifi@1 {
>>               reg = <1>;
>>               compatible = "brcm,bcm4329-fmac";
>>               interrupt-parent = <&pio>;
>>

[0] http://www.mail-archive.com/ath9k-devel-xDcbHBWguxHbcTqmT+pZeQ@public.gmane.org/msg14678.html
