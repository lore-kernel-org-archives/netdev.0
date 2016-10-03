From: Robert Jarzmik <robert.jarzmik-GANU6spQydw@public.gmane.org>
Subject: Re: [PATCH 3/3] net: smsc911x: add u16 workaround for pxa platforms
Date: Mon, 03 Oct 2016 18:14:39 +0200
Message-ID: <87k2dp9zps.fsf@belgarion.home>
References: <1475485553-18747-1-git-send-email-robert.jarzmik@free.fr>
        <1475485553-18747-3-git-send-email-robert.jarzmik@free.fr>
        <5b835e36-d53b-7510-25fb-649abc7df775@arm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Nicolas Pitre <nico-vtqb6HGKxmzR7s880joybQ@public.gmane.org>,
        Russell King - ARM Linux <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>,
        Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jeremy Linton <jeremy.linton-5wv7dgnIgG8@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5b835e36-d53b-7510-25fb-649abc7df775-5wv7dgnIgG8@public.gmane.org> (Jeremy Linton's
        message of "Mon, 3 Oct 2016 10:21:15 -0500")
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Jeremy Linton <jeremy.linton-5wv7dgnIgG8@public.gmane.org> writes:

> Hi Robert,
>
> On 10/03/2016 04:05 AM, Robert Jarzmik wrote:
>> Add a workaround for mainstone, idp and stargate2 boards, for u16 writes
>> which must be aligned on 32 bits addresses.
>>
>> Signed-off-by: Robert Jarzmik <robert.jarzmik-GANU6spQydw@public.gmane.org>
>> ---
>>  Documentation/devicetree/bindings/net/smsc911x.txt | 2 ++
>>  1 file changed, 2 insertions(+)
>
> I think this might be the wrong doc file. I think you want the
> smsc-lan91c111.txt file.
Ah yes, thanks for spoting that.

Cheers.

--
Robert
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
