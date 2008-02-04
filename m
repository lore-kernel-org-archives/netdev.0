From: Andrew Morton <akpm@linux-foundation.org>
Subject: include/linux/pcounter.h
Date: Mon, 4 Feb 2008 01:44:02 -0800
Message-ID: <20080204014402.1c55d3fe.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754645AbYBDJoj@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


e7d0362dd41e760f340c1b500646cc92522bd9d5 should have been folded into
de4d1db369785c29d68915edfee0cb70e8199f4c prior to merging.  We now and for
ever have a window of breakage which screws up git bisection.  Which I
just hit.  Which is the only reason I discovered the file's existence.


Please do not merge pieces of generic kernel infrastructure while keeping
it all secret on the netdev list.  Ever.  That code has a number of deficiencies
which I and probably others would have noted had it been offered to us
for review.
