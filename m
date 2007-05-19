From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] [TCP] Sysctl: document tcp_max_ssthresh (Limited
 Slow-Start)
Date: Sat, 19 May 2007 10:24:01 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0705191018590.23269@kivilampi-30.cs.helsinki.fi>
References: <Pine.LNX.4.64.0705181926570.22402@kivilampi-30.cs.helsinki.fi>
 <464DE584.7030008@ev-en.org> <464E00E5.5050801@hp.com> <464E1144.4010806@psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hp.com>, Baruch Even <baruch@ev-en.org>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: John Heffner <jheffner@psc.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:58437 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754214AbXESHYD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 May 2007 03:24:03 -0400
In-Reply-To: <464E1144.4010806@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 18 May 2007, John Heffner wrote:

> Rick Jones wrote:
> > as an asside, "tcp_max_ssthresh" sounds like the maximum value ssthresh can
> > take-on.  is that correct, or is this more of a "once ssthresh is above
> > this, behave in this new way?"  If that is the case, while the 
> 
> I don't like it either, but you'll have to talk to Sally Floyd about that
> one.. ;)
> 
> In general, I would like the documentation to emphasize more how to set the
> parameter than describe the algorithm.  The max_ssthresh parameter should
> ideally be set to the bottleneck queue size, or more realistically a
> conservative value that's likely to be smaller than the bottleneck queue
> size.  When max_ssthresh is smaller than the bottleneck queue, (limited) slow
> start will not overflow it until cwnd has fully ramped up to the appropriate
> size.

...You probably know such things much better than I do, so could you 
please write it then...

-- 
 i.
