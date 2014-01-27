From: Max Filippov <jcmvbkbc-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 3/3] net: ethoc: document OF bindings
Date: Tue, 28 Jan 2014 00:45:05 +0400
Message-ID: <CAMo8BfLhFyOY1+FJ0qh8iL969totUCmHdJ0LzyqBAzwi1-Ht=A@mail.gmail.com>
References: <1390795167-6677-1-git-send-email-jcmvbkbc@gmail.com>
	<1390795167-6677-4-git-send-email-jcmvbkbc@gmail.com>
	<CAL_JsqLjn4FXrNGLGHs639TEqmQKPx_kk9JbAd-hn7mexzAjNg@mail.gmail.com>
	<CAMo8BfKm_rzDDs9BpfQkaew9DP9T8y0RnjzT_1gzs9Xrbx2CLA@mail.gmail.com>
	<CAGVrzcb4Y8zu6Q24-0d-uKppGE=HrvEXPUD2-Mo8r5JC80nDSw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Rob Herring <robherring2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"linux-xtensa-PjhNF2WwrV/0Sa2dR60CXw@public.gmane.org" <linux-xtensa-PjhNF2WwrV/0Sa2dR60CXw@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Chris Zankel <chris-YvXeqwSYzG2sTnJN9+BGXg@public.gmane.org>,
	Marc Gauthier <marc-vna1KIf7WgpBDgjK7y7TUQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Grant Likely <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Rob Herring <rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org>
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAGVrzcb4Y8zu6Q24-0d-uKppGE=HrvEXPUD2-Mo8r5JC80nDSw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 27, 2014 at 11:45 PM, Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> 2014-01-27 Max Filippov <jcmvbkbc-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>:
>> On Mon, Jan 27, 2014 at 6:10 PM, Rob Herring <robherring2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>>> On Sun, Jan 26, 2014 at 9:59 PM, Max Filippov <jcmvbkbc-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:

[...]

>>>> --- /dev/null
>>>> +++ b/Documentation/devicetree/bindings/net/opencores-ethoc.txt
>>>> @@ -0,0 +1,25 @@
>>>> +* OpenCores MAC 10/100 Mbps
>>>> +
>>>> +Required properties:
>>>> +- compatible: Should be "opencores,ethoc".
>>>
>>> There are not different versions of IP or is the version probeable?
>>
>> AFAIK there's single version of this 10/100 MAC.
>> It doesn't have any identification registers.
>
> Since this is an IP block that people can modify due to its open
> source nature, it would have been good to define a revision register
> or such which would allow software to gate specific code based on that
> revision.

Probably yes, though I haven't heard of any modified versions of this MAC
out there.

[...]

>>>> +Examples:
>>>> +
>>>> +       enet0: ethoc@fd030000 {
>>>> +               compatible = "opencores,ethoc";
>>>> +               reg = <0xfd030000 0x4000 0xfd800000 0x4000>;
>>>> +               interrupts = <1>;
>>>> +               local-mac-address = [00 50 c2 13 6f 00];
>>>> +               clock-frequency = <50000000>;
>>>> +               mii-mgmt-clock-frequency = <5000000>;
>
> 5Mhz management clock? Can't you make it work with the standard 2.5Mhz
> management clock? Is not there a risk not to be able to "talk" to some
> PHY chips out there which do not support > 2.5Mhz management clock?

Yes I can, it just didn't occur to me that there is a standard 2.5MHz setting.

> Since this is an ethoc specific property, should it be prefixed with "ethoc,"?

Is it worth keeping this parameter at all, or just always default to 2.5MHz?

-- 
Thanks.
-- Max
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
