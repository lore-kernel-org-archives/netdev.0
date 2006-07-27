From: David Miller <davem@davemloft.net>
Subject: Re: async network I/O, event channels, etc
Date: Thu, 27 Jul 2006 01:37:07 -0700 (PDT)
Message-ID: <20060727.013707.101482735.davem@davemloft.net>
References: <20060727081114.GH5282@suse.de>
	<20060727.012037.78156999.davem@davemloft.net>
	<20060727082924.GK5282@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, drepper@redhat.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:15309
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932151AbWG0Igs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jul 2006 04:36:48 -0400
To: axboe@suse.de
In-Reply-To: <20060727082924.GK5282@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jens Axboe <axboe@suse.de>
Date: Thu, 27 Jul 2006 10:29:24 +0200

> Precisely. And this is the bit that is currently still broken for
> splice-to-socket, since it gives that ack right after ->sendpage() has
> been called. But that's a known deficiency right now, I think Alexey is
> currently looking at that (as well as receive side support).

That's right, I was discussing this with him just a few days ago.

It's good to hear that he's looking at those patches you were working
on several months ago.
