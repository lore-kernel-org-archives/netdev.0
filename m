From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net-next] fast_hash: clobber registers correctly for
 inline function use
Date: Fri, 14 Nov 2014 11:02:28 -0800
Message-ID: <CAHA+R7NKrwE7F4k4wiaZRJ67QAhB9bUe8SdyuT8Ky3-wAou6cA@mail.gmail.com>
References: <1415978022.15154.31.camel@localhost>
	<1415979181.17262.45.camel@edumazet-glaptop2.roam.corp.google.com>
	<1415979978.15154.41.camel@localhost>
	<20141114.133829.1437047454714311242.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@nicira.com>, jay.vosburgh@canonical.com,
	discuss@openvswitch.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f169.google.com ([209.85.216.169]:51311 "EHLO
	mail-qc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965567AbaKNTC3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2014 14:02:29 -0500
Received: by mail-qc0-f169.google.com with SMTP id w7so79149qcr.0
        for <netdev@vger.kernel.org>; Fri, 14 Nov 2014 11:02:29 -0800 (PST)
In-Reply-To: <20141114.133829.1437047454714311242.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 14, 2014 at 10:38 AM, David Miller <davem@davemloft.net> wrote:
>
> Also, I am strongly of the opinion that this is a mis-use of the
> alternative call interface.  It was never intended to be used for
> things that can make real function calls.
>
> You can add a million clobbers, or a trampoline, it's still using a
> facility in a manner for which it was not designed.
>
> This means a new interface with a new name and with capabilities
> explicitly supporting this case are in order.
>

I am wondering, compare with alternative call, how slower is just testing
cpu_has_xmm4_2?
