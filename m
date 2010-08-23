From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Bugme-new] [Bug 16626] New: Machine hangs with EIP at
 skb_copy_and_csum_dev
Date: Mon, 23 Aug 2010 16:14:37 +0200
Message-ID: <20100823141437.GA2282@del.dom.local>
References: <20100820193835.GA6025@del.dom.local>
 <20100821074742.GA2367@del.dom.local>
 <1282377058.2636.12.camel@edumazet-laptop>
 <20100821080735.GA2409@del.dom.local>
 <4C725FCB.2000304@fs.uni-ruse.bg>
 <20100823124736.GA16966@ff.dom.local>
 <1282568443.2486.34.camel@edumazet-laptop>
 <20100823131056.GA19160@ff.dom.local>
 <4C727B06.2060002@fs.uni-ruse.bg>
 <4C72802D.8090405@fs.uni-ruse.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Plamen Petrov <pvp-lsts@fs.uni-ruse.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:49812 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751861Ab0HWOOo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 10:14:44 -0400
Received: by bwz11 with SMTP id 11so3904384bwz.19
        for <netdev@vger.kernel.org>; Mon, 23 Aug 2010 07:14:43 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4C72802D.8090405@fs.uni-ruse.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 23, 2010 at 05:05:33PM +0300, Plamen Petrov wrote:
> Well, so far - so good. No oopses.
> 
> I think I'm hitting some compiler related issue here...
> 
> The kernel with the patch I sent applied is working pretty fine
> even with "generic-receive-offload" ON for my tg3 nic...
> 
> What is the big difference there?

Oopses should be replaced with warnings, so please check the
syslog etc from time to time.

Jarek P.
