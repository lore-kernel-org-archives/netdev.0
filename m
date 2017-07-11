From: Arend van Spriel <arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH] brcmfmac: added LED triggers for transmit/receive
Date: Tue, 11 Jul 2017 10:58:03 +0200
Message-ID: <60de1301-b4a3-95a7-117f-a953576655d9@broadcom.com>
References: <20170707140941.122115-1-russell.joyce@york.ac.uk>
 <CACna6rzY84oWNMBfP8N4A=Sxst_8b-S+rTbZFQV0yFcOR5MceQ@mail.gmail.com>
 <B8983FA2-39CE-478B-80C9-F32E01856FE9@york.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Alan Millard <alan.millard-3oYoeGyd3e21Qrn1Bg8BZw@public.gmane.org>,
        Franky Lin <franky.lin-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Hante Meuleman <hante.meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Chi-Hsien Lin <chi-hsien.lin-+wT8y+m8/X5BDgjK7y7TUQ@public.gmane.org>,
        Wright Feng <wright.feng-+wT8y+m8/X5BDgjK7y7TUQ@public.gmane.org>,
        Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
        Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
        "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Pieter-Paul Giesberts <pieter-paul.giesberts-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <rafal-g1n6cQUeyibVItvQsEIGlw@public.gmane.org>,
        "mhiramat-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org" <mhiramat-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        James Hughes <james.hughes-FnsA7b+Nu9XbIbC87yuRow@public.gmane.org>,
        Tobias Klauser <tklauser-93Khv+1bN0NyDzI6CaY1VQ@public.gmane.org>,
        Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "open list:BROADCOM BRCM80211 IEEE802.11n W
To: Russell Joyce <russell.joyce-3oYoeGyd3e21Qrn1Bg8BZw@public.gmane.org>,
        =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <B8983FA2-39CE-478B-80C9-F32E01856FE9-3oYoeGyd3e21Qrn1Bg8BZw@public.gmane.org>
Content-Language: en-US
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 10-07-17 19:02, Russell Joyce wrote:
>> 1) I think most of it should be some cfg80211 shareable code.
> 
> I’m not sure exactly what you mean by this, could you please clarify?

What I think Rafał is saying is that it would be better to have this
code in cfg80211 so other drivers including mac80211 could use it.

>> 2) This "rxtx" while surely present in other places sounds like a
>> workaround for LED subsystem limitation. Maybe it's time to finally
>> rework LED triggers.
> 
> I agree that it’s not an ideal way to do things, but I couldn’t think of a
> better alternative. I think that having a combined trigger is useful though, for
> situations like using the single LED on a Raspberry Pi to show Wi-Fi activity.

Indeed. However, the LED subsystem could/should(?) take care of mapping
"rx" and "tx" triggers to the same LED.

I am happy to comment on your patch, but maybe you can first take a look
at the suggestion Rafał made above.

Regards,
Arend
