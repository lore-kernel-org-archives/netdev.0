From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: severe regression in alx ethernet driver
Date: Wed, 25 Nov 2015 23:47:08 +0100
Message-ID: <20151125224708.GA1640@electric-eye.fr.zoreil.com>
References: <CAKM02HMP3WsRYTsm7UVR4tD1jMO5dHrDn6TXg9ARHo-Wqyq2oQ@mail.gmail.com>
 <CAKM02HMMu_FVwSR7OpeyKQ=AUiCqwsjKgOCJJppJJG=tqz0Nog@mail.gmail.com>
 <20151123.111530.2081520486357118720.davem@davemloft.net>
 <20151123.111610.2054291192576855643.davem@davemloft.net>
 <20151124160739.GG38006@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, ldap.tester@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jarod Wilson <jarod@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151124160739.GG38006@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarod Wilson <jarod@redhat.com> :
[...]
> They do at least have a signed-off-by in the patches attached to the bug,
> so I'm working on touching up the descriptions and formatting, regression
> testing them on my laptop that has an alx-driven E2200 in it (which isn't
> affected by this bug), and then I can ship them up for proper review.

You can forget the last refill-me-harder patch and save a roundtrip.
The driver should 1) prohibit holes in its receive ring, 2) allocate before
pushing data up in the stack and 3) drop packets when it can't allocate a
fresh buffer.

-- 
Ueimor
