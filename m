From: Thomas Graf <tgraf@infradead.org>
Subject: Re: [RFC] random SYN drops causing connect() delays
Date: Mon, 12 Apr 2010 04:39:03 -0400
Message-ID: <20100412083903.GA19763@bombadil.infradead.org>
References: <20100412080633.GA27418@bombadil.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:46747 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752525Ab0DLIjE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Apr 2010 04:39:04 -0400
Received: from tgr by bombadil.infradead.org with local (Exim 4.69 #1 (Red Hat Linux))
	id 1O1FAd-0005ns-LV
	for netdev@vger.kernel.org; Mon, 12 Apr 2010 08:39:03 +0000
Content-Disposition: inline
In-Reply-To: <20100412080633.GA27418@bombadil.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 12, 2010 at 04:06:33AM -0400, Thomas Graf wrote:
>  - While the issue is appearing, the acceptq seems to be overflowing. Both
>    LISTENOVERFLOWS and LISTENDROPS are increasing although not by the exact
>    number of delay occurences. inetdiag reports sk_max_ack_backlog to be 0
>    therefore one possibility that comes to mind is that sk_ack_backlog
>    underflows due to a race.

Forget about the underflow thought, inetdiag was reporting falsely.
sk_max_ack_backlog is set to 128 as it should and the listen overflow
happens normally. Still the fact remains that while the issue is appearing
listen overflows are counted.
