From: Mike Frysinger <vapier.adi@gmail.com>
Subject: Re: [PATCH 2/5] netdev: bfin_mac: fix malformed UDP packet
	transmission when polling with KGDB
Date: Fri, 29 May 2009 07:42:15 -0400
Message-ID: <8bd0f97a0905290442v5942bf9fj6d4926e900ce1aa9@mail.gmail.com>
References: <8bd0f97a0905290346v542e83cdg321241f0b4d95d9e@mail.gmail.com>
	 <20090529.035224.124353374.davem@davemloft.net>
	 <8bd0f97a0905290420g454c3affr21b6f05e5971d93@mail.gmail.com>
	 <20090529.042726.135473158.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org,
	sonic.zhang@analog.com, cooloney@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.28]:53034 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757657AbZE2LmN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 07:42:13 -0400
Received: by yx-out-2324.google.com with SMTP id 3so3300494yxj.1
        for <netdev@vger.kernel.org>; Fri, 29 May 2009 04:42:15 -0700 (PDT)
In-Reply-To: <20090529.042726.135473158.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 29, 2009 at 07:27, David Miller wrote:
> From: Mike Frysinger <vapier.adi@gmail.com>
>> that isnt how the DMA is being used here. =C2=A0there is no register=
 to
>> read back because the DMA controller is doing the reading indirectly=
=2E
>> but along those lines, it's not entirely clear which DMA registers
>> this SSYNC is supposed to be protecting because all of the updates a=
re
>> happening on the descriptors in external memory, not the DMA registe=
rs
>> themselves. =C2=A0i'll have Sonic clarify.
>
> Yes, that's really confusing because the commit message says
> "registers".

the SSYNC() is still correct, but the comment is wrong/misleading as
it isnt protecting the DMA registers, it's flushing the internal write
buffers
-mike
