From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Bugme-new] [Bug 16626] New: Machine hangs with EIP at
 skb_copy_and_csum_dev
Date: Tue, 24 Aug 2010 20:22:35 +0200
Message-ID: <20100824182235.GA3065@del.dom.local>
References: <20100823131056.GA19160@ff.dom.local>
 <4C727B06.2060002@fs.uni-ruse.bg>
 <4C72802D.8090405@fs.uni-ruse.bg>
 <20100823141437.GA2282@del.dom.local>
 <4C734FB5.1090702@fs.uni-ruse.bg>
 <1282626102.2378.1351.camel@edumazet-laptop>
 <4C738636.4000107@fs.uni-ruse.bg>
 <4C73C8DF.4060601@fs.uni-ruse.bg>
 <1282662532.2477.248.camel@edumazet-laptop>
 <courier.4C74007C.00000EE4@fs.ru.acad.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Plamen Petrov <pvp-lsts@fs.uni-ruse.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:63589 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752687Ab0HXSWl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 14:22:41 -0400
Received: by eyg5 with SMTP id 5so3581835eyg.19
        for <netdev@vger.kernel.org>; Tue, 24 Aug 2010 11:22:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <courier.4C74007C.00000EE4@fs.ru.acad.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 24, 2010 at 08:25:16PM +0300, Plamen Petrov wrote:
> Eric Dumazet ????????????:
...
> 
> Now what?

Good question. IMHO it looks like skbs are overwritten, so better turn
off gro until some next patch.

> 
> Thanks a lot, Eric and Jarek!

Thanks a lot, Plamen and Eric, too!

Jarek P.
