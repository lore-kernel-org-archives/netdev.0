From: jing wang <windsdaemon@gmail.com>
Subject: Re: [PATCH 1/1] af_unix.c: fix the compile warning in unix_bind
Date: Fri, 26 Oct 2012 11:24:18 +0800
Message-ID: <508A0262.6010205@gmail.com>
References: <1351219727-6085-1-git-send-email-windsdaemon@gmail.com> <20121025.231641.1536209335816707842.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: edumazet@google.com, viro@zeniv.linux.org.uk, xemul@parallels.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:36234 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755807Ab2JZDY2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2012 23:24:28 -0400
Received: by mail-da0-f46.google.com with SMTP id n41so1090183dak.19
        for <netdev@vger.kernel.org>; Thu, 25 Oct 2012 20:24:27 -0700 (PDT)
In-Reply-To: <20121025.231641.1536209335816707842.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Thanks for your review and i'm sorry about this, the warning is :

CC net/unix/af_unix.o
net/unix/af_unix.c: In function 'unix_bind':
net/unix/af_unix.c:895: warning: 'path.dentry' may be used uninitialize=
d=20
in this function
net/unix/af_unix.c:895: warning: 'path.mnt' may be used uninitialized i=
n=20
this function


=E4=BA=8E 2012=E5=B9=B410=E6=9C=8826=E6=97=A5 11:16, David Miller =E5=86=
=99=E9=81=93:
> From: Jing Wang <windsdaemon@gmail.com>
> Date: Fri, 26 Oct 2012 10:48:47 +0800
>
>> Signed-off-by: Jing Wang <windsdaemon@gmail.com>
> What compile warning?  You need to describe what problem
> you are solving, rather than assume we can figure it out
> by reading your patch.
>
>> -
>> +
> This doesn't do anything and should be in your patch.
