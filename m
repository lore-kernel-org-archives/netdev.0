From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] poll: Avoid extra wakeups in select/poll
Date: Tue, 28 Apr 2009 17:00:13 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0904281700030.15947@qirst.com>
References: <alpine.DEB.1.10.0904241554100.29995@qirst.com> <49F3308B.1030507@cosmosbay.com> <20090426.020411.157511269.davem@davemloft.net> <49F43B8F.2050907@cosmosbay.com> <87ab60rh8t.fsf@basil.nowhere.org> <49F71B63.8010503@cosmosbay.com>
 <alpine.DEB.1.10.0904281501300.13862@qirst.com> <49F76174.6060009@cosmosbay.com> <alpine.DEB.1.10.0904281612560.13862@qirst.com> <49F767FD.2040205@cosmosbay.com> <alpine.DEB.1.10.0904281629090.15947@qirst.com> <49F76F6C.80005@cosmosbay.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux kernel <linux-kernel@vger.kernel.org>,
	Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>, jesse.brandeburg@intel.com,
	netdev@vger.kernel.org, haoki@redhat.com, mchan@broadcom.com,
	davidel@xmailserver.org, Ingo Molnar <mingo@elte.hu>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ultrahosting.com ([74.213.174.254]:53782 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751315AbZD1VJe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2009 17:09:34 -0400
In-Reply-To: <49F76F6C.80005@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 28 Apr 2009, Eric Dumazet wrote:

> BNX2 interrupts first handle TX completions, then RX events.
> So If by the

Guess there is more to come?

