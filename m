From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: How to compile tcp fast open client app with kernel tfo client
 support ?
Date: Fri, 9 Nov 2012 12:54:08 -0800
Message-ID: <CAGK4HS_SpdECk_KCu98Z1X9W02G9j9u7QE9B6qHEnTXLeZbqgA@mail.gmail.com>
References: <CAK3+h2xmgy+RhUy=MZ5Cu8Zpz+gQmt3dXCX0tpLAWFCTeujBLA@mail.gmail.com>
	<CAGK4HS-U+Ov5x8z+1CRZdiAD9MhfBUfurKKBbt1EWGYFLN8TcA@mail.gmail.com>
	<CAK3+h2z5=n6BHGzPjfbrJS4MbVGQ2pdMQP54dOZ8M=8xigUd3Q@mail.gmail.com>
	<CAK6E8=fc=hYppk=4+tnNF9UPvQNFhw8YKo-ebG2y6FwXTft_EQ@mail.gmail.com>
	<CAK3+h2xAqjs8CvkcwXiFryyQhDnohsN7-0KfQVjpegZh_AD1eg@mail.gmail.com>
	<1352492823.19779.825.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Vincent Li <vincent.mc.li@gmail.com>,
	Yuchung Cheng <ycheng@google.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:39035 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755131Ab2KIUyI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2012 15:54:08 -0500
Received: by mail-oa0-f46.google.com with SMTP id h16so4480738oag.19
        for <netdev@vger.kernel.org>; Fri, 09 Nov 2012 12:54:08 -0800 (PST)
In-Reply-To: <1352492823.19779.825.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9 November 2012 12:27, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2012-11-09 at 12:17 -0800, Vincent Li wrote:
>
>> I have tried to run fresh build net-next, for some reason the build
>> stops ssh service from starting up, tried 3.7.0-rc4 too, same issue. I
>> don't know if it is new kernel bug or ubuntu upstart bug, but that is
>> another issue.
>>
>
> Not sure Ubuntu 10.04 binaries can run a 3.7 kernel.
>
> Some bug fixes in kernel need bug fixes in userland.
>
> You could try a bisection ?
>
 I saw the same issue with Ubuntu starting around 3.7.0-rc1 but 3.6
was fine if I recall. (I did a partial bisection but was not sure it
was a kernel issue)
 sshd would not start up on boot and I 'fixed' it by adding the
following in /etc/rc.local since I assumed it was a userspace issue.

if [ ! -d /var/run/sshd ]; then
   mkdir /var/run/sshd
   chmod 0755 /var/run/sshd
fi
/usr/sbin/sshd


Thanks,
Vijay
