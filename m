From: Tony Prisk <linux-ci5G2KO2hbZ+pU9mqzGVBQ@public.gmane.org>
Subject: Re: [PATCH 3/3] net: via-rhine: add OF bus binding
Date: Wed, 29 Jan 2014 16:44:41 +1300
Message-ID: <52E87929.30708@prisktech.co.nz>
References: <1385227995-3956-1-git-send-email-alchark@gmail.com>	<1390823503-24087-1-git-send-email-alchark@gmail.com>	<1390823503-24087-4-git-send-email-alchark@gmail.com>	<CAL_JsqLi0QKeeUkGMKmYZ1ki02mzk=L1gDxTJyXFGiOe_aHiVw@mail.gmail.com> <CABjd4Yxo0Pp+QtTuXhKBT9KdVhUk12x2L8+FBL_ZWmPYopG2JQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Roger Luethi <rl-7uj+XXdSDtwfv37vnLkPlQ@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Alexey Charkov <alchark-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Rob Herring <robherring2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CABjd4Yxo0Pp+QtTuXhKBT9KdVhUk12x2L8+FBL_ZWmPYopG2JQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 29/01/14 07:27, Alexey Charkov wrote:
> 2014/1/27 Rob Herring <robherring2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>:
>> On Mon, Jan 27, 2014 at 5:51 AM, Alexey Charkov <alchark-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>>> This should make the driver usable with VIA/WonderMedia ARM-based
>>> Systems-on-Chip integrated Rhine III adapters. Note that these
>>> are always in MMIO mode, and don't have any known EEPROM.
>>>
>>> Signed-off-by: Alexey Charkov <alchark-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>>> Signed-off-by: Roger Luethi <rl-7uj+XXdSDtwfv37vnLkPlQ@public.gmane.org>
>>> ---
>>>   .../devicetree/bindings/net/via-rhine.txt          |  18 ++
>>>   drivers/net/ethernet/via/Kconfig                   |   2 +-
>>>   drivers/net/ethernet/via/via-rhine.c               | 293 +++++++++++++--------
>>>   3 files changed, 200 insertions(+), 113 deletions(-)
>>>   create mode 100644 Documentation/devicetree/bindings/net/via-rhine.txt
>>>
>>> diff --git a/Documentation/devicetree/bindings/net/via-rhine.txt b/Documentation/devicetree/bindings/net/via-rhine.txt
>>> new file mode 100644
>>> index 0000000..684dd3a
>>> --- /dev/null
>>> +++ b/Documentation/devicetree/bindings/net/via-rhine.txt
>>> @@ -0,0 +1,18 @@
>>> +* VIA Rhine 10/100 Network Controller
>>> +
>>> +Required properties:
>>> +- compatible : Should be "via,rhine"
>> This should be more specific rather than...
>>
>>> +- reg : Address and length of the io space
>>> +- interrupts : Should contain the controller interrupt line
>>> +- rhine,revision : Rhine core revision, used to inform the
>>> +       driver of quirks and capabilities to expect from
>>> +       the device. Mimics the respective PCI attribute.
>> having this property. The OF match table can then have the quirks set
>> based on compatible strings.
> Sounds fair. Do you think something like the following would fly?
>
> Required properties:
> - compatible : Should be "via,rhine-soc-vt8500" for integrated Rhine
> cores found in SoC's such as VIA VT8500, WonderMedia WM8950 and
> possibly others. These are listed as 1106:3106 rev. 0x84 on the
> virtual PCI bus under vendor-provided kernels.
Does it need a special name? I would have assumed they are using their 
own IP for the VT6105 or VT6106S.
Then you can use it to add quirks later on if needed.

Regards
Tony Prisk
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
