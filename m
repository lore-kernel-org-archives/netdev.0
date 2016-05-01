From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: Q: How to disable vlan strip in Intel igb driver ?
Date: Sun, 1 May 2016 10:08:29 -0700
Message-ID: <CAKgT0UcZ310qcrxQGqSu9+WWwKMukPPgpqPa=HRO0-oO8Tx_4g@mail.gmail.com>
References: <CAJ2oMhKyMbgLZiGSGQxRGVdbGARvMHeO3=vpgO0uOzOBqvf79Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>
To: Ran Shalit <ranshalit@gmail.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:37843 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751467AbcEARIa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 May 2016 13:08:30 -0400
Received: by mail-ig0-f175.google.com with SMTP id s8so58061318ign.0
        for <netdev@vger.kernel.org>; Sun, 01 May 2016 10:08:29 -0700 (PDT)
In-Reply-To: <CAJ2oMhKyMbgLZiGSGQxRGVdbGARvMHeO3=vpgO0uOzOBqvf79Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 1, 2016 at 6:13 AM, Ran Shalit <ranshalit@gmail.com> wrote:
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

You should be able to turn off the offload by setting
"rx-vlan-offload" to "off" via "ethtool -K".

- Alex
