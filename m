From: Harini Katakam <harinikatakamlinux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC PATCH 3/3] devicetree: macb: Add optional property tsu-clk
Date: Mon, 14 Sep 2015 09:39:05 +0530
Message-ID: <CAFcVECK=EONgqPq1jt_kti-VKXPWGVj3OSnqUvo0YcR65Z+Phg@mail.gmail.com>
References: <1441958258-35441-1-git-send-email-harinik@xilinx.com>
	<1441958258-35441-4-git-send-email-harinik@xilinx.com>
	<20150911165256.GT19678@xsjsorenbubuntu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Harini Katakam <harini.katakam-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>,
	Nicolas Ferre <nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
	Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	"ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org" <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
	Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	boris.brezillon-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org,
	alexandre.belloni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Punnaiah Choudary Kalluri <punnaia-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>,
	"michals-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org" <michals-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>, anirudh-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org
To: =?UTF-8?Q?S=C3=B6ren_Brinkmann?= <soren.brinkmann-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150911165256.GT19678@xsjsorenbubuntu>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 11, 2015 at 10:22 PM, S=C3=B6ren Brinkmann
<soren.brinkmann-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org> wrote:
> Hi Harini,
>
> On Fri, 2015-09-11 at 01:27PM +0530, Harini Katakam wrote:
>> Add TSU clock frequency to be used for 1588 support in macb driver.
>>
>> Signed-off-by: Harini Katakam <harinik-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
>> ---
>>  Documentation/devicetree/bindings/net/macb.txt |    3 +++
>>  1 file changed, 3 insertions(+)
>>
>> diff --git a/Documentation/devicetree/bindings/net/macb.txt b/Docume=
ntation/devicetree/bindings/net/macb.txt
>> index b5d7976..f7c0ea8 100644
>> --- a/Documentation/devicetree/bindings/net/macb.txt
>> +++ b/Documentation/devicetree/bindings/net/macb.txt
>> @@ -19,6 +19,9 @@ Required properties:
>>       Optional elements: 'tx_clk'
>>  - clocks: Phandles to input clocks.
>>
>> +Optional properties:
>> +- tsu-clk: Time stamp unit clock frequency used.
>
> Why are we not using the CCF and a clk_get_rate() in the driver?
>

If the clock source was only internal, we could use this
approach as usual. But TSU clock can be configured to
come from an external clock source or internal.

Regards,
Harini
--
To unsubscribe from this list: send the line "unsubscribe devicetree" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
