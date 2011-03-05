From: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [patch net-next-2.6 7/8] net: introduce rx_handler results and
 logic around that
Date: Sat, 05 Mar 2011 15:52:19 +0100
Message-ID: <4D724E23.7020904@gmail.com>
References: <1299320969-7951-1-git-send-email-jpirko@redhat.com>	 <1299320969-7951-8-git-send-email-jpirko@redhat.com> <1299329330.4277.97.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	davem@davemloft.net, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	andy@greyhouse.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:46475 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751861Ab1CEOwW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Mar 2011 09:52:22 -0500
Received: by wyg36 with SMTP id 36so3016439wyg.19
        for <netdev@vger.kernel.org>; Sat, 05 Mar 2011 06:52:21 -0800 (PST)
In-Reply-To: <1299329330.4277.97.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 05/03/2011 13:48, Ben Hutchings a =C3=A9crit :
> On Sat, 2011-03-05 at 11:29 +0100, Jiri Pirko wrote:
>> This patch allows rx_handlers to better signalize what to do next to
>> it's caller. That makes skb->deliver_no_wcard no longer needed.
> [...]
>> --- a/include/linux/netdevice.h
>> +++ b/include/linux/netdevice.h
>> @@ -390,7 +390,14 @@ enum gro_result {
>>   };
>>   typedef enum gro_result gro_result_t;
>>
>> -typedef struct sk_buff *rx_handler_func_t(struct sk_buff *skb);
>> +enum rx_handler_result {
>> +	RX_HANDLER_CONSUMED,
>> +	RX_HANDLER_ANOTHER,
>> +	RX_HANDLER_EXACT,
>> +	RX_HANDLER_PASS,
>> +};
> [...]
>
> This should have a comment (preferably kernel-doc) clearly specifying
> the meaning of each code, as the differences between ANOTHER/EXACT/PA=
SS
> are fairly subtle.
>
> Ben,

Except from the lack of proper documentation, this patch looks very goo=
d.

	Nicolas.
