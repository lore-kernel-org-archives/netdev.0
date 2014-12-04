From: Kevin Zhu <Mingying.Zhu-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>
Subject: Re: Is this 32-bit NCM?y
Date: Thu, 4 Dec 2014 09:01:46 +0000
Message-ID: <548022F5.2090701@audiocodes.com>
References: <alpine.LNX.2.03.1411262250160.4356@gmail.com>
 <alpine.LNX.2.03.1412012202480.1301@gmail.com>
 <B315C8AC-3B33-406B-A728-14F8FAAAE986@audiocodes.com>
 <547D37CA.7050506@audiocodes.com>
 <alpine.LNX.2.03.1412020729470.1351@gmail.com>
 <547D5F84.6020608@audiocodes.com>
 <alpine.LNX.2.03.1412020747360.1921@gmail.com>
 <547D6D7B.5090704@audiocodes.com>
 <E0C3DF2A36210C42B1AB4626A0E10F1FD949424C@aclmbx01.corp.audiocodes.com>
 <547D7243.80508@audiocodes.com>
 <alpine.LNX.2.03.1412021130410.2697@gmail.com> <87fvcyqoup.fsf@nemi.mork.no>
 <alpine.LNX.2.03.1412021410270.29633@gmail.com>
 <87lhmqp400.fsf@nemi.mork.no>,<alpine.LNX.2.03.1412021453340.7488@gmail.com>
 <1417532733483.89987@audiocodes.com>
 <alpine.LNX.2.03.1412021627360.8131@gmail.com>
 <547EA1D1.8010202@audiocodes.com>
 <alpine.LNX.2.03.1412030659001.1288@gmail.com>
 <547EA82F.5050500@audiocodes.com>
 <alpine.LNX.2.03.1412040730480.1320@gmail.com>
 <548020DD.3030705@audiocodes.com>
 <alpine.LNX.2.03.1412040955140.3516@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=Windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?Windows-1252?Q?Bj=F8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>,
	Eli Britstein <Eli.Britstein-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>,
	Alex Strizhevsky <alexxst-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Midge Shaojun Tan" <ShaojunMidge.Tan-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>,
	"youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.LNX.2.03.1412040955140.3516-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Content-Language: en-US
Content-ID: <7D37745E6CC76A41BAD56842ABD2BF6C-NhzUejbdEhGcE4WynfumptQqCkab/8FMAL8bYrjMMd8@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

It looks windows disable it, so I just follow it. Maybe enabling it wil=
l
be also OK. I have not tried. I do not find it in hw_cdc_driver.

Regards,
Kevin

On 12/04/2014 04:56 PM, Enrico Mioso wrote:
> Hi Kevin.
> Thank you for your hints and work.
> Only a note - why disabling ARP? I think it could be a good iea... or
> does the hw_cdc_driver do that?
> thank you again,
> Enrico
>
>
>
> On Thu, 4 Dec 2014, Kevin Zhu wrote:
>
>> Date: Thu, 4 Dec 2014 09:52:49
>> From: Kevin Zhu <Mingying.Zhu-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>
>> To: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> Cc: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>, Eli Britstein
>> <Eli.Britstein-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>,
>>     Alex Strizhevsky <alexxst-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
>>     Midge Shaojun  Tan <ShaojunMidge.Tan-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>,
>>     "youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
>>     "linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
>>     "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
>> Subject: Re: Is this 32-bit NCM?y
>>
>> Guys,
>>
>> After rearranging the padding, putting NCM0 right after NTH, and dis=
able
>> ARP (FLAG_NOARP) and handling the offset alignment issue, it seems i=
t
>> begins to work, though there's still problem with DHCP. It's able to
>> ping, though my Ubuntu network manage does not notice this network
>> interface. So no DNS.
>>
>> I have to specify the network interface and IP in the ping command.
>>
>> The DHCP packet's size becomes a large one after the TX function, wh=
ich
>> is 16384, the maximum. And the dongle does not reply it in time. For
>> now, I just simple rearrange the code to meet Huawei's alignment
>> requirement. I think other devices may be different, regarding the
>> 'offset' definition. We may need to handle it. And also need to doub=
le
>> check if the code has bugs.
>>
>> Regards,
>> Kevin
>>
>> On 12/04/2014 02:31 PM, Enrico Mioso wrote:
>>> Hello guys!
>>> I am writing this message to hear if there is any progress,
>>> Enrico
>>>
>>>
>>> On Wed, 3 Dec 2014, Kevin Zhu wrote:
>>>
>>>> Date: Wed, 3 Dec 2014 07:05:37
>>>> From: Kevin Zhu <Mingying.Zhu-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>
>>>> To: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>>>> Cc: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>, Eli Britstein
>>>> <Eli.Britstein-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>,
>>>>     Alex Strizhevsky <alexxst-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
>>>>     Midge Shaojun  Tan <ShaojunMidge.Tan-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>,
>>>>     "youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
>>>>     "linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
>>>>     "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
>>>> Subject: Re: Is this 32-bit NCM?
>>>>
>>>> OK. I will. Thank you for everything!
>>>>
>>>> Regards,
>>>> Kevin
>>>>
>>>> On 12/03/2014 02:00 PM, Enrico Mioso wrote:
>>>>> Yes - I think this would be ok. You might try this with the 16-bi=
t
>>>>> river first,
>>>>> and then with the 32-bit one to see how things work.
>>>>> I hope for the best.
>>>>> Let us all know,
>>>>> Enrico
>>>>>
>>>>>
>>>>> On Wed, 3 Dec 2014, Kevin Zhu wrote:
>>>>>
>>>>> =3D=3DDate: Wed, 3 Dec 2014 06:38:27
>>>>> =3D=3DFrom: Kevin Zhu <Mingying.Zhu-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>
>>>>> =3D=3DTo: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>>>>> =3D=3DCc: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>, Eli Britstein
>>>>> <Eli.Britstein-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>,
>>>>> =3D=3D    Alex Strizhevsky <alexxst-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
>>>>> =3D=3D    Midge Shaojun  Tan <ShaojunMidge.Tan-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>,
>>>>> =3D=3D    "youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
>>>>> =3D=3D    "linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>=
,
>>>>> =3D=3D    "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
>>>>> =3D=3DSubject: Re: Is this 32-bit NCM?
>>>>> =3D=3D
>>>>> =3D=3DMy dongle also works with the huawei driver. I think only t=
he 32bit
>>>>> =3D=3Dformat and NDP location matter. We may modify the TX functi=
on to
>>>>> put NTH
>>>>> =3D=3Dand NDP at the beginning of a NTB and see if it will work w=
ith the
>>>>> =3D=3Ddriver cdc_ncm.
>>>>> =3D=3D
>>>>> =3D=3DRegards,
>>>>> =3D=3DKevin
>>>>> =3D=3D
>>>>> =3D=3DOn 12/02/2014 11:28 PM, Enrico Mioso wrote:
>>>>> =3D=3D> ... And what do you think about the source code of their =
ndis
>>>>> driver?
>>>>> =3D=3D> We at least know now the device work with it, so we have
>>>>> something to mimic :D
>>>>> =3D=3D> thank you for your work and patience Kevin.
>>>>> =3D=3D>
>>>>> =3D=3D> On Tue, 2 Dec 2014, Kevin Zhu wrote:
>>>>> =3D=3D>
>>>>> =3D=3D> =3D=3DDate: Tue, 2 Dec 2014 16:04:25
>>>>> =3D=3D> =3D=3DFrom: Kevin Zhu <Mingying.Zhu-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>
>>>>> =3D=3D> =3D=3DTo: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Bj=F8rn Mor=
k
>>>>> <bjorn-yOkvZcmFvRU@public.gmane.org>
>>>>> =3D=3D> =3D=3DCc: Eli Britstein <Eli.Britstein-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>,
>>>>> =3D=3D> =3D=3D    Alex Strizhevsky <alexxst-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
>>>>> =3D=3D> =3D=3D    Midge Shaojun  Tan <ShaojunMidge.Tan@audiocodes=
=2Ecom>,
>>>>> =3D=3D> =3D=3D    "youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
>>>>> =3D=3D> =3D=3D    "linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY@public.gmane.org=
nel.org>,
>>>>> =3D=3D> =3D=3D    "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TaqPxH82wqD4g@public.gmane.org=
g>
>>>>> =3D=3D> =3D=3DSubject: Re: Is this 32-bit NCM?
>>>>> =3D=3D> =3D=3D
>>>>> =3D=3D> =3D=3DI do not understand why the wSequence matters. By t=
he way, I
>>>>> think I see some NDPs are right after NTH headers in the windows
>>>>> capture.
>>>>> =3D=3D> =3D=3D
>>>>> =3D=3D> =3D=3D________________________________________
>>>>> =3D=3D> =3D=3DFrom: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>>>>> =3D=3D> =3D=3DSent: Tuesday, December 2, 2014 21:53
>>>>> =3D=3D> =3D=3DTo: Bj=F8rn Mork
>>>>> =3D=3D> =3D=3DCc: Kevin Zhu; Eli Britstein; Alex Strizhevsky; Mid=
ge Shaojun
>>>>> Tan; youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org; linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org;
>>>>> netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>>>>> =3D=3D> =3D=3DSubject: Re: Is this 32-bit NCM?
>>>>> =3D=3D> =3D=3D
>>>>> =3D=3D> =3D=3DThank you very much Bjorn.
>>>>> =3D=3D> =3D=3D
>>>>> =3D=3D> =3D=3D
>>>>> =3D=3D> =3D=3DOn Tue, 2 Dec 2014, Bj=F8rn Mork wrote:
>>>>> =3D=3D> =3D=3D
>>>>> =3D=3D> =3D=3D=3D=3DDate: Tue, 2 Dec 2014 14:37:03
>>>>> =3D=3D> =3D=3D=3D=3DFrom: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
>>>>> =3D=3D> =3D=3D=3D=3DTo: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>>>>> =3D=3D> =3D=3D=3D=3DCc: Kevin Zhu <Mingying.Zhu-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>,
>>>>> =3D=3D> =3D=3D=3D=3D    Eli Britstein <Eli.Britstein@audiocodes.c=
om>,
>>>>> =3D=3D> =3D=3D=3D=3D    Alex Strizhevsky <alexxst-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
>>>>> =3D=3D> =3D=3D=3D=3D    Midge Shaojun Tan <ShaojunMidge.Tan@audio=
codes.com>,
>>>>> =3D=3D> =3D=3D=3D=3D    "youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
>>>>> =3D=3D> =3D=3D=3D=3D    "linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb@vg=
er.kernel.org>,
>>>>> =3D=3D> =3D=3D=3D=3D    "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY@public.gmane.org=
nel.org>
>>>>> =3D=3D> =3D=3D=3D=3DSubject: Re: Is this 32-bit NCM?
>>>>> =3D=3D> =3D=3D=3D=3D
>>>>> =3D=3D> =3D=3D=3D=3DEnrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
>>>>> =3D=3D> =3D=3D=3D=3D
>>>>> =3D=3D> =3D=3D=3D=3D> ... but out of curiosity: are NCM specs all=
owing to change
>>>>> order of things in
>>>>> =3D=3D> =3D=3D=3D=3D> the package or not?
>>>>> =3D=3D> =3D=3D=3D=3D> This is not to start philosofical falames o=
r something,
>>>>> but to understand
>>>>> =3D=3D> =3D=3D=3D=3D> better how things work. And, if they do: ho=
w much
>>>>> arbitrarily?
>>>>> =3D=3D> =3D=3D=3D=3D
>>>>> =3D=3D> =3D=3D=3D=3DOnly the NTB header has a fixed location. The=
 rest can be
>>>>> anywhere and
>>>>> =3D=3D> =3D=3D=3D=3Din any order. Quoting from section 3 Data Tra=
nsport:
>>>>> =3D=3D> =3D=3D=3D=3D
>>>>> =3D=3D> =3D=3D=3D=3D  "Within any given NTB, the NTH always must =
be first; but
>>>>> the other
>>>>> =3D=3D> =3D=3D=3D=3D   items may occur in arbitrary order."
>>>>> =3D=3D> =3D=3D=3D=3D
>>>>> =3D=3D> =3D=3D=3D=3D
>>>>> =3D=3D> =3D=3D=3D=3DBj=F8rn
>>>>> =3D=3D> =3D=3D=3D=3D
>>>>> =3D=3D> =3D=3DThis email and any files transmitted with it are co=
nfidential
>>>>> material. They are intended solely for the use of the designated
>>>>> individual or entity to whom they are addressed. If the reader of
>>>>> this message is not the intended recipient, you are hereby notifi=
ed
>>>>> that any dissemination, use, distribution or copying of this
>>>>> communication is strictly prohibited and may be unlawful.
>>>>> =3D=3D> =3D=3D
>>>>> =3D=3D> =3D=3DIf you have received this email in error please imm=
ediately
>>>>> notify the sender and delete or destroy any copy of this message
>>>>> =3D=3D> =3D=3D
>>>>> =3D=3DThis email and any files transmitted with it are confidenti=
al
>>>>> material. They are intended solely for the use of the designated
>>>>> individual or entity to whom they are addressed. If the reader of
>>>>> this message is not the intended recipient, you are hereby notifi=
ed
>>>>> that any dissemination, use, distribution or copying of this
>>>>> communication is strictly prohibited and may be unlawful.
>>>>> =3D=3D
>>>>> =3D=3DIf you have received this email in error please immediately=
 notify
>>>>> the sender and delete or destroy any copy of this message
>>>>> =3D=3D
>>>> This email and any files transmitted with it are confidential
>>>> material. They are intended solely for the use of the designated
>>>> individual or entity to whom they are addressed. If the reader of
>>>> this message is not the intended recipient, you are hereby notifie=
d
>>>> that any dissemination, use, distribution or copying of this
>>>> communication is strictly prohibited and may be unlawful.
>>>>
>>>> If you have received this email in error please immediately notify
>>>> the sender and delete or destroy any copy of this message
>>>>
>> This email and any files transmitted with it are confidential
>> material. They are intended solely for the use of the designated
>> individual or entity to whom they are addressed. If the reader of
>> this message is not the intended recipient, you are hereby notified
>> that any dissemination, use, distribution or copying of this
>> communication is strictly prohibited and may be unlawful.
>>
>> If you have received this email in error please immediately notify
>> the sender and delete or destroy any copy of this message
>>
This email and any files transmitted with it are confidential material.=
 They are intended solely for the use of the designated individual or e=
ntity to whom they are addressed. If the reader of this message is not =
the intended recipient, you are hereby notified that any dissemination,=
 use, distribution or copying of this communication is strictly prohibi=
ted and may be unlawful.

If you have received this email in error please immediately notify the =
sender and delete or destroy any copy of this message
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
