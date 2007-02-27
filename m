From: "Luca Tettamanti" <kronos.it@gmail.com>
Subject: Re: [BUG][2.6.21] af_key: kernel BUG at net/core/skbuff.c:93
Date: Tue, 27 Feb 2007 17:34:21 +0100
Message-ID: <68676e00702270834j17bf7e4bgd50b6e271404927f@mail.gmail.com>
References: <20070226220841.GA7727@dreamland.darkstar.lan>
	 <20070227090127.GA1625@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Jarek Poplawski" <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.233]:27470 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751006AbXB0QeW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Feb 2007 11:34:22 -0500
Received: by nz-out-0506.google.com with SMTP id s1so1620774nze
        for <netdev@vger.kernel.org>; Tue, 27 Feb 2007 08:34:21 -0800 (PST)
In-Reply-To: <20070227090127.GA1625@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/27/07, Jarek Poplawski <jarkao2@o2.pl> wrote:
> On 26-02-2007 23:08, Luca Tettamanti wrote:
> > Hello,
> > I'm running 2.6.21 (current git, at 9654640d0af). kernel blows up at
> > startup, when running setkey. Kernel 2.6.20 runs fine. A couple of words
> ...
> > ------------[ cut here ]------------
> > kernel BUG at /home/kronos/src/linux-2.6.git/net/core/skbuff.c:93!
> > invalid opcode: 0000 [#1]
>
> Hi!
>
> Could you repeat this with: CONFIG_4KSTACKS=n ?

Actually I cannot repeat after a make clean, with either stack
configurations. The original kernel still consistently dies in the
same point though. Must have been a mis-compilation :(
Sorry for the noise.

Luca
