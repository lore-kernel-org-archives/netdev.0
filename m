From: =?UTF-8?Q?Peter_Pal=c3=bach?= <Peter.Paluch@fri.uniza.sk>
Subject: Re: Q: How to disable vlan strip in Intel igb driver ?
Date: Sun, 1 May 2016 20:22:11 +0200
Message-ID: <afa69dcb-0905-a556-0208-49a2363ae818@fri.uniza.sk>
References: <CAJ2oMhKyMbgLZiGSGQxRGVdbGARvMHeO3=vpgO0uOzOBqvf79Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Ran Shalit <ranshalit@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from castor.kis.fri.uniza.sk ([158.193.152.2]:46748 "EHLO
	mail.kis.fri.uniza.sk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751639AbcEASWT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 May 2016 14:22:19 -0400
In-Reply-To: <CAJ2oMhKyMbgLZiGSGQxRGVdbGARvMHeO3=vpgO0uOzOBqvf79Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ran,

How are you accessing the VLAN tag information - and how do you know 
that the VLAN tag is not being passed through? Are you using AF_PACKET 
socket in your application?

Best regards,
Peter


On 01.05.2016 15:13, Ran Shalit wrote:
> Hello,
>
>
> I am using intel igb driver in Linux.
>
> The driver strip the packet from vlan inofmation. But we need this
> information in the packet.
>
> We tried to change build flag, or see if there is any feature with
> ethtool that can disable this feature, but nothing helps.
>
>
> Is there any way to achive this ?
>
> Regards,
>
> Ran
