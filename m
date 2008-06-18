From: David Miller <davem@davemloft.net>
Subject: Re: netlink circular locking dependency
Date: Tue, 17 Jun 2008 21:30:12 -0700 (PDT)
Message-ID: <20080617.213012.132043917.davem@davemloft.net>
References: <20080617132410.GB4632@ff.dom.local>
	<4857BBB6.6010709@trash.net>
	<20080617134303.GC4632@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, marcel@holtmann.org, netdev@vger.kernel.org,
	mingo@elte.hu, tgraf@suug.ch
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37132
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752100AbYFREaM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 00:30:12 -0400
In-Reply-To: <20080617134303.GC4632@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Tue, 17 Jun 2008 13:43:03 +0000

> On Tue, Jun 17, 2008 at 03:27:18PM +0200, Patrick McHardy wrote:
> ...
> > I guess that might work. But simply using module references to
> > prevent the module from going away while the mutex is not held
> > doesn't appear to be more complicated.
> 
> O.K.

In the meantime should I apply Patrick's current patch
from this thread?

If so I'd like a proper commit message and signoff, thanks!
