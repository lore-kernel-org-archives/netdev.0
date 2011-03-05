From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [patch net-next-2.6 7/8] net: introduce rx_handler results and
 logic around that
Date: Sat, 05 Mar 2011 16:06:44 +0100
Message-ID: <4D725184.5090707@gmail.com>
References: <1299320969-7951-1-git-send-email-jpirko@redhat.com> <1299320969-7951-8-git-send-email-jpirko@redhat.com> <1299329330.4277.97.camel@localhost> <4D724E23.7020904@gmail.com> <20110305145408.GD8573@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	davem@davemloft.net, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	andy@greyhouse.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:64623 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751076Ab1CEPGr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Mar 2011 10:06:47 -0500
Received: by wwe15 with SMTP id 15so1167214wwe.1
        for <netdev@vger.kernel.org>; Sat, 05 Mar 2011 07:06:46 -0800 (PST)
In-Reply-To: <20110305145408.GD8573@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 05/03/2011 15:54, Jiri Pirko a =E9crit :
> Sat, Mar 05, 2011 at 03:52:19PM CET, nicolas.2p.debian@gmail.com wrot=
e:
>> Le 05/03/2011 13:48, Ben Hutchings a =E9crit :
>>> On Sat, 2011-03-05 at 11:29 +0100, Jiri Pirko wrote:
>>>> This patch allows rx_handlers to better signalize what to do next =
to
>>>> it's caller. That makes skb->deliver_no_wcard no longer needed.
>>> [...]
>>>> --- a/include/linux/netdevice.h
>>>> +++ b/include/linux/netdevice.h
>>>> @@ -390,7 +390,14 @@ enum gro_result {
>>>>   };
>>>>   typedef enum gro_result gro_result_t;
>>>>
>>>> -typedef struct sk_buff *rx_handler_func_t(struct sk_buff *skb);
>>>> +enum rx_handler_result {
>>>> +	RX_HANDLER_CONSUMED,
>>>> +	RX_HANDLER_ANOTHER,
>>>> +	RX_HANDLER_EXACT,
>>>> +	RX_HANDLER_PASS,
>>>> +};
>>> [...]
>>>
>>> This should have a comment (preferably kernel-doc) clearly specifyi=
ng
>>> the meaning of each code, as the differences between ANOTHER/EXACT/=
PASS
>>> are fairly subtle.
>>>
>>> Ben,
>>
>> Except from the lack of proper documentation, this patch looks very =
good.
>
> Okay guys, I'll write something about that and send it in another pat=
ch.

Agreed that it can be in a follow-up patch.

Reviewed-by: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>
