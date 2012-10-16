From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: bpf filter : support for vlan tag
Date: Tue, 16 Oct 2012 19:06:32 +0200
Message-ID: <1350407192.3954.1254.camel@edumazet-glaptop>
References: <CAOxq_8MqMatY2+GA6+mHjj5V=Xe7Y8BmuX4r6cz5nChU5C1Vzw@mail.gmail.com>
	 <1350369998.3954.563.camel@edumazet-glaptop>
	 <CAD6jFUTn98+i_0eh6gc-CYgVXHNLbZdZmV6==mL+duFM-oNRmg@mail.gmail.com>
	 <1350386917.3954.890.camel@edumazet-glaptop>
	 <CAOxq_8NKn96RPE327L54c0zozdksT5dEhaKGMP+7rV4VMMbT+g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <danborkmann@iogearbox.net>, netdev@vger.kernel.org
To: Ani Sinha <ani@aristanetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:57192 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755098Ab2JPRGh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2012 13:06:37 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so3140719bkc.19
        for <netdev@vger.kernel.org>; Tue, 16 Oct 2012 10:06:36 -0700 (PDT)
In-Reply-To: <CAOxq_8NKn96RPE327L54c0zozdksT5dEhaKGMP+7rV4VMMbT+g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-10-16 at 09:54 -0700, Ani Sinha wrote:
> On Tue, Oct 16, 2012 at 4:28 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> >
> > Note that if speed is needed, we also want to update various JIT
> > implementations.
> >
> 
> Thanks Eric for the patch. I will take a look at it. We also need the
> JIT module support as well (for x86 and x86_64) since we use the JIT
> filter. I have been studying the various instructions and how other
> filter operations have been implemented using them but it will take me
> a little bit more time to understand the code.

Dont worry, I'll do the JIT part (but only for x86_64, we dont support
i386)
