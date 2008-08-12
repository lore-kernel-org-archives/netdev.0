From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: tbench regression on each kernel release from 2.6.22 -> 2.6.28
Date: Tue, 12 Aug 2008 11:13:15 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0808121058550.4551@wrl-59.cs.helsinki.fi>
References: <48A086B6.2000901@linux-foundation.org> <20080811.141501.01468546.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cl@linux-foundation.org, Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:48387 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751575AbYHLINS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2008 04:13:18 -0400
In-Reply-To: <20080811.141501.01468546.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 11 Aug 2008, David Miller wrote:

> From: Christoph Lameter <cl@linux-foundation.org>
> Date: Mon, 11 Aug 2008 13:36:38 -0500
> 
> > It seems that the network stack becomes slower over time? Here is a list of
> > tbench results with various kernel versions:
> > 
> > 2.6.22		3207.77 mb/sec
> > 2.6.24		3185.66
> > 2.6.25		2848.83
> > 2.6.26		2706.09
> > 2.6.27(rc2)	2571.03
> > 
> > And linux-next is:
> > 
> > 2.6.28(l-next)	2568.74
> > 
> > It shows that there is still have work to be done on linux-next. Too close to
> > upstream in performance.
> > 
> > Note the KT event between 2.6.24 and 2.6.25. Why is that?
> 
> Isn't that when some major scheduler changes went in?  I'm not blaming
> the scheduler, but rather I'm making the point that there are other
> subsystems in the kernel that the networking interacts with that
> influences performance at such a low level.

...IIRC, somebody in the past did even bisect his (probably netperf) 
2.6.24-25 regression to some scheduler change (obviously it might or might 
not be related to this case of yours)...


-- 
 i.
