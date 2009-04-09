From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: Re: converting fs_enet to net_device_ops
Date: Thu, 9 Apr 2009 18:50:35 +0400
Message-ID: <a4423d670904090750x38b0411al246b7b57fe50a24b@mail.gmail.com>
References: <C7C29031-E717-4D83-874A-DC0D1E12BA3D@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Anton Vorontsov <avorontsov@ru.mvista.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Linux PPC Development <linuxppc-dev@ozlabs.org>
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f165.google.com ([209.85.219.165]:61077 "EHLO
	mail-ew0-f165.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755083AbZDIOuh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2009 10:50:37 -0400
Received: by ewy9 with SMTP id 9so718677ewy.37
        for <netdev@vger.kernel.org>; Thu, 09 Apr 2009 07:50:36 -0700 (PDT)
In-Reply-To: <C7C29031-E717-4D83-874A-DC0D1E12BA3D@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2009/4/9 Kumar Gala <galak@kernel.crashing.org>:
> Can someone look at converting drivers/net/fs_enet over to the new
> net_device_ops.
>
> Dave,
>
> Are you willing to take such a patch in for .30? =C2=A0Otherwise we n=
eed to add a
> select COMPAT_NET_DEV_OPS in Kconfig for this driver (and any others =
that
> might not have been converted over). =C2=A0drivers/net/ibm_newemac/ i=
s another.

Hi
I did not this mail.
I have sent a patch for it.
http://patchwork.ozlabs.org/patch/25781/
