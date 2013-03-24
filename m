From: Jason Oster <parasytic@gmail.com>
Subject: Re: Missing TCP SYN on loopback, retransmits after 1s
Date: Sat, 23 Mar 2013 17:08:29 -0700
Message-ID: <02604F4C-1288-4739-86C9-6EB8322E4C7A@gmail.com>
References: <20111122.192338.1206677511966747729.davem@davemloft.net> <20111122183727.01ab6f04@telperion.jlyo.org> <1322059124.17693.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <20111123.172959.909786536317740314.davem@davemloft.net> <c873451a-71aa-418b-96e2-d8875e7fec3e@googlegroups.com> <1364057885.29473.4.camel@edumazet-glaptop> <B0544E9D-BC59-449D-88A5-6DAFCB676F91@gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 6.3 \(1503\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: jlyo@jlyo.org, netdev@vger.kernel.org, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:61962 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752296Ab3CXAId convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Mar 2013 20:08:33 -0400
Received: by mail-pb0-f50.google.com with SMTP id up1so3555950pbc.23
        for <netdev@vger.kernel.org>; Sat, 23 Mar 2013 17:08:32 -0700 (PDT)
In-Reply-To: <B0544E9D-BC59-449D-88A5-6DAFCB676F91@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi again,

Resending this; it didn't make it to the netdev list.

On Mar 23, 2013, at 12:17 PM, Jason Oster <parasytic@gmail.com> wrote:

> Hello Eric,
> 
> Thank you for looking into this so quickly! And it sounds like promising news, too. I'll experiment with newer kernels right away.
> 
> Thanks again,
> Jay


FYI net-next may have some changes not available in 3.9.0-rc3, because I can still reproduce it there:

$ uname -a
Linux test 3.9.0-030900rc3-generic #201303171935 SMP Sun Mar 17 23:36:17 UTC 2013 x86_64 x86_64 x86_64 GNU/Linux

This is from the Ubuntu kernel mainline PPA (on Raring Ringtail-dev). I haven't built the kernel yet.