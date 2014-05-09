From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [3.15-rc3] Bisected: xen-netback mangles packets between two
 guests on a bridge since merge of "TX grant mapping with SKBTX_DEV_ZEROCOPY
 instead of copy" series.
Date: Fri, 9 May 2014 18:19:08 -0400
Message-ID: <CADVnQymtPHaqKHwd=mwQwe0i8oVY=njOZY1SsPj8prodNMQfbw@mail.gmail.com>
References: <395225650.20140430124506@eikelenboom.it>
	<536250F9.7060405@citrix.com>
	<1967602892.20140501160513@eikelenboom.it>
	<53626563.8010404@citrix.com>
	<1046603646.20140501174053@eikelenboom.it>
	<1399044933.29914.242.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sander Eikelenboom <linux@eikelenboom.it>,
	Zoltan Kiss <zoltan.kiss@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, xen-devel@lists.xen.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:38799 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757079AbaEIWTK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2014 18:19:10 -0400
Received: by mail-wi0-f177.google.com with SMTP id f8so2015562wiw.4
        for <netdev@vger.kernel.org>; Fri, 09 May 2014 15:19:09 -0700 (PDT)
In-Reply-To: <1399044933.29914.242.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 2, 2014 at 11:35 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2014-05-01 at 17:40 +0200, Sander Eikelenboom wrote:
>
>> Yesterday i tried to get packetdrill (https://code.google.com/p/packetdrill/) to
>> work to see if i could reproduce with one of it's tests, but didn't get the
>> client server stuff working. It seems it has helped with finding and fixing
>> previous kernel networking bugs.
>
> If you use recent net-next kernel, you need a packetdrill patch, Neal
> might submit it shortly on packetdrill repo.
>
> packetdrill currently does not consume the packets sent on the tun
> device, so this triggers the new [1] TCP stack behavior detecting packet
> did not yet leaved the host.
>
> [1] :
> ( http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=1f3279ae0c13cd742731726b0ed195d5f09b14e4 )

I have submitted the fix to the packetdrill repo. If you "git pull"
the latest packetdrill sources then its "local mode" should work again
for net-next. Sorry if the delay has caused any hassles.

neal
