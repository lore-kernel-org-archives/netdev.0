From: Huajun Li <huajun.li.lee@gmail.com>
Subject: Re: write() udp socket
Date: Sun, 24 Jul 2011 16:33:10 +0800
Message-ID: <CA+v9cxZAF27mXc6aCEPyOdqbeLved3_xibvDS4TQugHR=7owPg@mail.gmail.com>
References: <tencent_287F494544728EDB6DA9C8ED@qq.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: ZHOU Xiaobo <xb.zhou@qq.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f52.google.com ([209.85.161.52]:62550 "EHLO
	mail-fx0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751374Ab1GXIdL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jul 2011 04:33:11 -0400
Received: by fxd18 with SMTP id 18so7364537fxd.11
        for <netdev@vger.kernel.org>; Sun, 24 Jul 2011 01:33:10 -0700 (PDT)
In-Reply-To: <tencent_287F494544728EDB6DA9C8ED@qq.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/7/23 ZHOU Xiaobo <xb.zhou@qq.com>:
> question No1:
> When I call
> ssize_t write(int fd, const void *buf, size_t count);
>
>
> on a nonblocking UDP socket, is the return value =A0always equal to '=
count'?
>
>

I don't think so.  The function may be interrupt by signal or return
due to other reason, so the return value only represents the size it
writes successfully to the fd.

> question No2:
> Can I write() a UDP socket in multiple threads without locking?
>

In my opinion, you could. However, the receiver may not get what you ex=
pected.
>
> thanks
>
>
> ------------------
> Sincerely yours
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ZHOU Xiaobo
