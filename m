From: =?ISO-8859-1?Q?D=E2niel?= Fraga <fragabr@gmail.com>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility
 workaround (fwd)
Date: Wed, 1 Oct 2008 18:14:24 -0300
Message-ID: <48e3e835.0906c00a.2cd1.2fd1@mx.google.com>
References: <Pine.LNX.4.64.0810011546371.1034@wrl-59.cs.helsinki.fi>
	<48e3a4e5.0d1d640a.4cd3.06e9@mx.google.com>
	<alpine.LFD.1.10.0810012140360.5549@apollo.tec.linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Cc: Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.168]:42069 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750769AbYJAVOb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 17:14:31 -0400
Received: by wf-out-1314.google.com with SMTP id 27so759658wfd.4
        for <netdev@vger.kernel.org>; Wed, 01 Oct 2008 14:14:30 -0700 (PDT)
In-Reply-To: <alpine.LFD.1.10.0810012140360.5549@apollo.tec.linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 1 Oct 2008 22:05:09 +0200 (CEST)
Thomas Gleixner <tglx@linutronix.de> wrote:

> One possibility to get deeper insight into this problem is to use the
> function tracer and stop it once we notice the wreckage. 
> listenoverflow should be a good point to stop it.

	Ok, I'm already running function tracer.

	I did the following:

echo ftrace > /debug/tracing/current_tracer
echo print-parent > /debug/tracing/iter_ctrl

	Is it enough to get what you suggest?

	If so, I'll leave it enabled:

echo 1 > /debug/tracing/tracing_enabled

	and stop and get the data just when the problem happens... then
I should know what I should grep, what's relevant.

	thank you again.


-- 
