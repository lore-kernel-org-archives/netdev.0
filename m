From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: Re: net-next Compile error
Date: Fri, 27 Oct 2017 19:38:39 +0200
Message-ID: <037dc273-6387-b549-d6b1-73d6315a465f@egil-hjelmeland.no>
References: <0adb27bc-e537-337e-c838-501cc14e964a@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aibo.runbox.com ([91.220.196.211]:41596 "EHLO aibo.runbox.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932190AbdJ0RjS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 27 Oct 2017 13:39:18 -0400
Received: from [10.9.9.211] (helo=mailfront11.runbox.com)
        by mailtransmit02.runbox with esmtp (Exim 4.86_2)
        (envelope-from <privat@egil-hjelmeland.no>)
        id 1e88bE-0003mb-Cw
        for netdev@vger.kernel.org; Fri, 27 Oct 2017 19:39:16 +0200
Received: from 93.89.126.26.ip.vitnett.no ([93.89.126.26] helo=[192.168.202.41])
        by mailfront11.runbox.com with esmtpsa  (uid:646232 )  (TLS1.2:DHE_RSA_AES_128_CBC_SHA1:128)
        (Exim 4.82)
        id 1e88ad-0006a2-Mq
        for netdev@vger.kernel.org; Fri, 27 Oct 2017 19:38:39 +0200
In-Reply-To: <0adb27bc-e537-337e-c838-501cc14e964a@egil-hjelmeland.no>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Den 27. okt. 2017 15:50, skrev Egil Hjelmeland:
> Starting with net-next commit 60e2a7780793bae0debc275a9ccd57f7da0cf195 
> "tcp: TCP experimental option for SMC", I can not cross compile the kernel.
> 
> In file included from ./include/asm-generic/unaligned.h:17:0,
>                   from ./arch/arm/include/generated/asm/unaligned.h:1,
>                   from net/ipv4/tcp_input.c:76:
> ./include/linux/unaligned/le_struct.h:6:19: note: previous definition of 
> 'get_unaligned_le16' was here
Hi Egil
Long since you did "make distclean"?

BR
Egil
