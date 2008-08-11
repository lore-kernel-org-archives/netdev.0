From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 11297] New: OOPS in rt6_fill_node
Date: Mon, 11 Aug 2008 14:32:12 -0700 (PDT)
Message-ID: <20080811.143212.172434871.davem@davemloft.net>
References: <20080809213101.0927a808.akpm@linux-foundation.org>
	<489F8827.4030904@hp.com>
	<82e4877d0808101805t55a6ec5ft6c9b171ac1c7c3ab@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brian.haley@hp.com, akpm@linux-foundation.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: parag.warudkar@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60060
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751492AbYHKVcL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2008 17:32:11 -0400
In-Reply-To: <82e4877d0808101805t55a6ec5ft6c9b171ac1c7c3ab@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Parag Warudkar" <parag.warudkar@gmail.com>
Date: Sun, 10 Aug 2008 21:05:07 -0400

> On Sun, Aug 10, 2008 at 8:30 PM, Brian Haley <brian.haley@hp.com> wrote:
> 
> > John sent me email off-line saying the patch fixed the problem, but he'd do
> > more testing over the weekend.
> 
> I did test the patch and it now spits out "EOF on netlink" like
> mentioned in bugzilla, which is not consistent with earlier behavior
> which was to output -
> unreachable fec0::1 dev lo  table unspec  proto none  src ::1  metric
> -1  error -101 hoplimit 255 .

We need to resolve this, Brian?
