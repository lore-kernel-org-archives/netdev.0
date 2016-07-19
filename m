From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH v3] packet: fix second argument of sock_tx_timestamp()
Date: Tue, 19 Jul 2016 12:31:34 -0400
Message-ID: <CAF=yD-L0qPdm-rNDz_KtkQQwUx1L8okwXH8457yrazfxwA=esA@mail.gmail.com>
References: <1468906851-8424-1-git-send-email-yoshihiro.shimoda.uh@renesas.com>
 <CACSApvYj5X166euM2Qy+ubvLYdfYg65itMYiVeTf5SUuiA+gog@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>,
	Soheil Hassas Yeganeh <soheil@google.com>,
	David Miller <davem@davemloft.net>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f65.google.com ([209.85.213.65]:36359 "EHLO
	mail-vk0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752983AbcGSQcP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2016 12:32:15 -0400
Received: by mail-vk0-f65.google.com with SMTP id r135so1937156vkf.3
        for <netdev@vger.kernel.org>; Tue, 19 Jul 2016 09:32:15 -0700 (PDT)
In-Reply-To: <CACSApvYj5X166euM2Qy+ubvLYdfYg65itMYiVeTf5SUuiA+gog@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 19, 2016 at 8:34 AM, Soheil Hassas Yeganeh
<soheil@google.com> wrote:
> On Tue, Jul 19, 2016 at 1:40 AM, Yoshihiro Shimoda
> <yoshihiro.shimoda.uh@renesas.com> wrote:
>> This patch fixes an issue that a syscall (e.g. sendto syscall) cannot
>> work correctly. Since the sendto syscall doesn't have msg_control buffer,
>> the sock_tx_timestamp() in packet_snd() cannot work correctly because
>> the socks.tsflags is set to 0.
>> So, this patch sets the socks.tsflags to sk->sk_tsflags as default.
>>
>> Fixes: c14ac9451c34 ("sock: enable timestamping using control messages")
>> Cc: <stable@vger.kernel.org>
>> Reported-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>> Reported-by: Keita Kobayashi <keita.kobayashi.ym@renesas.com>
>> Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
> Acked-by: Soheil Hassas Yeganeh <soheil@google.com>

Acked-by: Willem de Bruijn <willemb@google.com>
