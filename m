From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: NET_SCHED cbq dropping too many packets on a bonding interface
Date: Thu, 15 May 2008 09:12:17 +0000
Message-ID: <20080515091216.GA6550@ff.dom.local>
References: <B0A599AA8CD34E47901804F014F15903@uglypunk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Kingsley Foreman <kingsley@internode.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.187]:45649 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752429AbYEOJIt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2008 05:08:49 -0400
Received: by fk-out-0910.google.com with SMTP id 18so199899fkq.5
        for <netdev@vger.kernel.org>; Thu, 15 May 2008 02:08:48 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <B0A599AA8CD34E47901804F014F15903@uglypunk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15-05-2008 08:16, Kingsley Foreman wrote:
...
>>>> Ive been using qdisc for quite a while without any problems,
>>>> I just rebuilt a gentoo box with 2.6.25 kernel that does a lot of 
>>>> traffic
>>>> ~1000mbits+ over a bonded interface
>>>>
>>>> Im however seeing a big problem with cbq class dropping packets for no
>>>> reason i can see, and it is causing a lot of speed issues.
...

Do you mean the same box with the same config but the previous kernel
(2.6.24) doesn't show this problem? BTW, what is txqueuelen on this
bond0?

Regards,
Jarek P.
