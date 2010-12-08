From: "avagin@gmail.com" <avagin@gmail.com>
Subject: Re: [STABLE 2.6.32 PATCH] net: release dst entry while cache-hot
 for GSO case too
Date: Thu, 09 Dec 2010 01:47:41 +0300
Message-ID: <4D000B0D.2060101@gmail.com>
References: <20101011.085952.193718228.davem@davemloft.net>	<4CB33907.5060803@gmail.com>	<1286814652.2737.41.camel@edumazet-laptop> <20101026.115434.241921999.davem@davemloft.net>
Reply-To: avagin@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	mjt@tls.msk.ru, avagin@openvz.org, stable@kernel.org,
	netdev@vger.kernel.org, krkumar2@in.ibm.com
To: Greg Kroah-Hartman <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f171.google.com ([209.85.215.171]:58249 "EHLO
	mail-ey0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756548Ab0LHWrn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 17:47:43 -0500
Received: by eyg5 with SMTP id 5so1394179eyg.2
        for <netdev@vger.kernel.org>; Wed, 08 Dec 2010 14:47:42 -0800 (PST)
In-Reply-To: <20101026.115434.241921999.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Greg,

This patch is acked by David S. Miller. Greg, maybe you can commit it?

On 10/26/2010 10:54 PM, David Miller wrote:
> From: Eric Dumazet<eric.dumazet@gmail.com>
> Date: Mon, 11 Oct 2010 18:30:52 +0200
>
>> Le lundi 11 octobre 2010 =E0 20:19 +0400, Andrew Vagin a =E9crit :
>>> On 10/11/2010 07:59 PM, David Miller wrote:
>>>> From: Eric Dumazet<eric.dumazet@gmail.com>
>>>> Date: Mon, 11 Oct 2010 17:46:49 +0200
>>>>
>>>>> This patch was an optimization, not a bug fix.
>>>> Right, this has no business going into 2.6.32-stable at all.
>>> This is bug fix. Now nobody drops dst in case gso and veth, because=
 the
>>> commit 60df914e295a21a223e43a7ee01e0c73c64dd111 deletes skb_dst_dro=
p
>>> from the veth.c. We should commit my patch or revert commit 60df914=
e.
>>>
>>> We have two bug reports:
>>>
>>> http://www.spinics.net/lists/netdev/msg142104.html
>>>
>>> http://bugzilla.openvz.org/show_bug.cgi?id=3D1634
>>>
>>> Taylan verified that the patch really fix his bug.
>>
>> Now that makes sense ;)
>
> In case there is any doubt about this -stable patch submission:
>
> Acked-by: David S. Miller<davem@davemloft.net>

