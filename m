From: John Heffner <jheffner@psc.edu>
Subject: Re: [PATCH] [TCP] Sysctl: document tcp_max_ssthresh (Limited	Slow-Start)
Date: Fri, 18 May 2007 16:49:08 -0400
Message-ID: <464E1144.4010806@psc.edu>
References: <Pine.LNX.4.64.0705181926570.22402@kivilampi-30.cs.helsinki.fi> <464DE584.7030008@ev-en.org> <464E00E5.5050801@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Baruch Even <baruch@ev-en.org>,
	=?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:58785 "EHLO mailer1.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752203AbXERUtn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 May 2007 16:49:43 -0400
In-Reply-To: <464E00E5.5050801@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rick Jones wrote:
> as an asside, "tcp_max_ssthresh" sounds like the maximum value ssthresh 
> can take-on.  is that correct, or is this more of a "once ssthresh is 
> above this, behave in this new way?"  If that is the case, while the 

I don't like it either, but you'll have to talk to Sally Floyd about 
that one.. ;)

In general, I would like the documentation to emphasize more how to set 
the parameter than describe the algorithm.  The max_ssthresh parameter 
should ideally be set to the bottleneck queue size, or more 
realistically a conservative value that's likely to be smaller than the 
bottleneck queue size.  When max_ssthresh is smaller than the bottleneck 
queue, (limited) slow start will not overflow it until cwnd has fully 
ramped up to the appropriate size.

   -John
