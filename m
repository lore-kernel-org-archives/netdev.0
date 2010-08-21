From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Bugme-new] [Bug 16626] New: Machine hangs with EIP at
 skb_copy_and_csum_dev
Date: Sat, 21 Aug 2010 09:47:42 +0200
Message-ID: <20100821074742.GA2367@del.dom.local>
References: <4C6E5EA7.3040609@fs.uni-ruse.bg>
 <20100820193835.GA6025@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Plamen Petrov <pvp-lsts@fs.uni-ruse.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:41615 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751381Ab0HUHrw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Aug 2010 03:47:52 -0400
Received: by bwz11 with SMTP id 11so2676529bwz.19
        for <netdev@vger.kernel.org>; Sat, 21 Aug 2010 00:47:50 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20100820193835.GA6025@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 20, 2010 at 09:38:35PM +0200, Jarek Poplawski wrote:
> Plamen Petrov wrote, On 20.08.2010 12:53:
> > So, I guess its David and Herbert's turn?...
> 
> If you're bored in the meantime I'd suggest to do check the realtek
> driver eg:
> - for locking with the patch below,
> - to turn off with ethtool its tx-checksumming and/or scatter-gather,

After rethinking, it's almost impossible this patch could change
anything here, so don't bother, but consider mainly the second
proposal.

Jarek P.
