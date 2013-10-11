From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Peak TCP performance
Date: Thu, 10 Oct 2013 20:44:35 -0700
Message-ID: <1381463075.4971.99.camel@edumazet-glaptop.roam.corp.google.com>
References: <CAJoZ4U2eVUd4JiGQ6UFYMdoEwyN=MO8+9S3jGcsaYGN2vqt=3g@mail.gmail.com>
	 <1381461664.4971.97.camel@edumazet-glaptop.roam.corp.google.com>
	 <CAJoZ4U0tpKhknMLd7kN4uQmq-E81=EbH1Q816nX_eig=tGreAQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Kyle Hubert <khubert@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:43302 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751951Ab3JKDoh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Oct 2013 23:44:37 -0400
Received: by mail-pd0-f171.google.com with SMTP id g10so3562833pdj.30
        for <netdev@vger.kernel.org>; Thu, 10 Oct 2013 20:44:36 -0700 (PDT)
In-Reply-To: <CAJoZ4U0tpKhknMLd7kN4uQmq-E81=EbH1Q816nX_eig=tGreAQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-10-10 at 23:33 -0400, Kyle Hubert wrote:

> Ah, yes, sorry. I'm on 3.0.80 (SLES SP2). And, no, I do not have that
> commit. In fact, the code looks quite different. There must have been
> a lot of changes?
> 

Probably ;)

> Also, my copy of ethtool does not recognize tx-nocache-copy. However,
> I do have control over the net device. Is there something there I can
> set, or is tx-nocache-copy also a new feature? I'll start digging.
> 

nocache-copy was added in 3.0, but I do find its not a gain for current
cpus.

You could get a fresh copy of ethtool sources :

git clone git://git.kernel.org/pub/scm/network/ethtool/ethtool.git
cd ethtool
./autogen.sh  ...
