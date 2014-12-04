From: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Is this 32-bit NCM?y
Date: Thu, 4 Dec 2014 11:24:59 +0100 (CET)
Message-ID: <alpine.LNX.2.03.1412041124250.9684@gmail.com>
References: <AMSPR06MB6011E001029C251790CB923EE780@AMSPR06MB601.eurprd06.prod.outlook.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-364784635-1417688700=:9684"
Cc: =?ISO-8859-15?Q?Bj=F8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>,
	Kevin Zhu <Mingying.Zhu-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>,
	Eli Britstein <Eli.Britstein-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>,
	Alex Strizhevsky <alexxst-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Midge Shaojun Tan <ShaojunMidge.Tan-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <AMSPR06MB6011E001029C251790CB923EE780-MyG0ARRHH/drF+2gGhmTpL9PrO6axcR4XA4E9RH9d+qIuWR1G4zioA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-364784635-1417688700=:9684
Content-Type: TEXT/PLAIN; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8BIT

Congratulations!
Your modification to the driver work; the disable of padding itself alone did not.
With the modified file version I am able to use the device with no problems.
Congratulations guys.



On Thu, 4 Dec 2014, Midge Shaojun  Tan wrote:

> Date: Thu, 4 Dec 2014 11:10:16
> From: Midge Shaojun  Tan <ShaojunMidge.Tan-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>
> To: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Bjørn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
> Cc: Kevin Zhu <Mingying.Zhu-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>,
>     Eli Britstein <Eli.Britstein-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>,
>     Alex Strizhevsky <alexxst-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
>     "youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
>     "linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
>     "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
> Subject: Re: Is this 32-bit NCM?y
> 
> Hi all,
>
> I test OK with kervel 3.16.4
> Need disable other Ethernet network, just like eth1. (Then the DNS and route is OK)
> And also need disable arp, (ifconfig wwan0 -arp up), because China UNICOM don't respond the ARP message.
> With new mode switch string: /etc/usb_modeswitch.d/12d1:14fe
> Please see the patch and check whether it is correct?
>
>
> -----邮件原件-----
> 发件人: Enrico Mioso [mailto:mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org]
> 发送时间: 2014年12月4日 17:54
> 收件人: Bjørn Mork
> 抄送: Kevin Zhu; Eli Britstein; Alex Strizhevsky; Midge Shaojun Tan; youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org; linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> 主题: Re: Is this 32-bit NCM?y
>
> Guys!
> Don't forget I can test it - since I have a remote machine with 3.16 kernel and the device, at least for now.
> So - Bjorn: do I need just to disable padding or do I need also to perform some other changes? I am sorry if I ask this a little bit stupidly, but I was alittle bit busy here.
>
>
>
>
>
> On Thu, 4 Dec 2014, Bjørn Mork wrote:
>
>> Date: Thu, 4 Dec 2014 10:19:11
>> From: Bjørn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
>> To: Kevin Zhu <Mingying.Zhu-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>
>> Cc: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
>>     Eli Britstein <Eli.Britstein-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>,
>>     Alex Strizhevsky <alexxst-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
>>     Midge Shaojun Tan <ShaojunMidge.Tan-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>,
>>     "youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
>>     "linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
>>     "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
>> Subject: Re: Is this 32-bit NCM?y
>>
>> Kevin Zhu <Mingying.Zhu-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org> writes:
>>
>>> Guys,
>>>
>>> After rearranging the padding, putting NCM0 right after NTH, and
>>> disable ARP (FLAG_NOARP) and handling the offset alignment issue, it
>>> seems it begins to work, though there's still problem with DHCP.
>>
>> Great!  But it would be good to know if _one_ of these changes is
>> enough to make it work.
>>
>>> The DHCP packet's size becomes a large one after the TX function,
>>> which is 16384, the maximum.
>>
>> You can now (from v3.16) disable the padding by setting min_tx_pkt >= tx_max.
>> Something like this should do for a simple test:
>>
>> echo 16384 >/sys/class/net/wwan0/cdc_ncm/min_tx_pkt
>>
>>
>> Bjørn
>>
> This email and any files transmitted with it are confidential material. They are intended solely for the use of the designated individual or entity to whom they are addressed. If the reader of this message is not the intended recipient, you are hereby notified that any dissemination, use, distribution or copying of this communication is strictly prohibited and may be unlawful.
>
> If you have received this email in error please immediately notify the sender and delete or destroy any copy of this message
>
--8323328-364784635-1417688700=:9684--
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
