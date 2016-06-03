From: Craig Gallek <kraigatgoog@gmail.com>
Subject: Re: [PATCH] soreuseport: Fix reuseport_bpf testcase on 32bit architectures
Date: Fri, 3 Jun 2016 17:29:38 -0400
Message-ID: <CAEfhGiyS1Vk=etQcdu6n6NQDvOyc7zQC47PHi=0=8Z3HyvFxBQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexei Starovoitov <ast@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, linux-parisc@vger.kernel.org
To: Helge Deller <deller@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f50.google.com ([209.85.215.50]:36344 "EHLO
	mail-lf0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752535AbcFCV3l convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 17:29:41 -0400
Received: by mail-lf0-f50.google.com with SMTP id b73so62260420lfb.3
        for <netdev@vger.kernel.org>; Fri, 03 Jun 2016 14:29:40 -0700 (PDT)
Received: from mail-lf0-f49.google.com (mail-lf0-f49.google.com. [209.85.215.49])
        by smtp.gmail.com with ESMTPSA id c71sm626321lfe.27.2016.06.03.14.29.39
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Jun 2016 14:29:39 -0700 (PDT)
Received: by mail-lf0-f49.google.com with SMTP id b73so62260252lfb.3
        for <netdev@vger.kernel.org>; Fri, 03 Jun 2016 14:29:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 3, 2016 at 1:19 PM, Helge Deller <deller@gmx.de> wrote:
> This fixes the following compiler warnings when compiling the
> reuseport_bpf testcase on a 32 bit platform:
>
> reuseport_bpf.c: In function =E2=80=98attach_ebpf=E2=80=99:
> reuseport_bpf.c:114:15: warning: cast from pointer to integer of iffe=
rent size [-Wpointer-to-int-cast]
>
> Signed-off-by: Helge Deller <deller@gmx.de>
Acked-by: Craig Gallek <kraig@google.com>

Thanks!
