From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] net: release dst entry in dev_hard_start_xmit()
Date: Tue, 12 May 2009 22:24:41 +0200
Message-ID: <20090512202441.GC2757@ami.dom.local>
References: <49C380A6.4000904@cosmosbay.com> <4A092F59.7020900@cosmosbay.com> <4A093178.9020105@cosmosbay.com> <20090512192748.GA2757@ami.dom.local> <4A09D1B4.7070509@cosmosbay.com> <20090512200515.GB2757@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f222.google.com ([209.85.218.222]:53880 "EHLO
	mail-bw0-f222.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752086AbZELUZB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2009 16:25:01 -0400
Received: by bwz22 with SMTP id 22so211549bwz.37
        for <netdev@vger.kernel.org>; Tue, 12 May 2009 13:25:00 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090512200515.GB2757@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 12, 2009 at 10:05:15PM +0200, Jarek Poplawski wrote:
...
> Hmm..., if vlan, then why not pppoe (and/or maybe others in drivers/net/
> using dev_queue_xmit)?

I wonder if we can't simplify this e.g. by checking indirectly for
some hardware flag/capability like checksums etc. Some older hardware
could be omitted, by is it really so big deal?

Jarek P.
