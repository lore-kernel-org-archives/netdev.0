From: Ani Sinha <ani@aristanetworks.com>
Subject: Re: bpf filter : support for vlan tag
Date: Tue, 16 Oct 2012 09:54:31 -0700
Message-ID: <CAOxq_8NKn96RPE327L54c0zozdksT5dEhaKGMP+7rV4VMMbT+g@mail.gmail.com>
References: <CAOxq_8MqMatY2+GA6+mHjj5V=Xe7Y8BmuX4r6cz5nChU5C1Vzw@mail.gmail.com>
	<1350369998.3954.563.camel@edumazet-glaptop>
	<CAD6jFUTn98+i_0eh6gc-CYgVXHNLbZdZmV6==mL+duFM-oNRmg@mail.gmail.com>
	<1350386917.3954.890.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Daniel Borkmann <danborkmann@iogearbox.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:38973 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754742Ab2JPQyb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2012 12:54:31 -0400
Received: by mail-ie0-f174.google.com with SMTP id k13so10173055iea.19
        for <netdev@vger.kernel.org>; Tue, 16 Oct 2012 09:54:31 -0700 (PDT)
In-Reply-To: <1350386917.3954.890.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 16, 2012 at 4:28 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:

>
> Note that if speed is needed, we also want to update various JIT
> implementations.
>

Thanks Eric for the patch. I will take a look at it. We also need the
JIT module support as well (for x86 and x86_64) since we use the JIT
filter. I have been studying the various instructions and how other
filter operations have been implemented using them but it will take me
a little bit more time to understand the code.

Cheers,
ani
