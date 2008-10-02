From: =?ISO-8859-1?Q?D=E2niel?= Fraga <fragabr@gmail.com>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility
 workaround (fwd)
Date: Thu, 2 Oct 2008 17:56:59 -0300
Message-ID: <48e535a0.0504c00a.2dfa.00f2@mx.google.com>
References: <Pine.LNX.4.64.0810011546371.1034@wrl-59.cs.helsinki.fi>
	<48e3a4e5.0d1d640a.4cd3.06e9@mx.google.com>
	<alpine.LFD.1.10.0810012140360.5549@apollo.tec.linutronix.de>
	<48e3e835.0906c00a.2cd1.2fd1@mx.google.com>
	<alpine.LFD.1.10.0810021142370.5549@apollo.tec.linutronix.de>
	<48e4adb8.0807c00a.62b8.ffff87d6@mx.google.com>
	<alpine.LFD.1.10.0810021407400.5549@apollo.tec.linutronix.de>
	<48e4d63a.060ec00a.6a4e.ffff95bf@mx.google.com>
	<alpine.LFD.1.10.0810022113540.5549@apollo.tec.linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Cc: Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.169]:54874 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754121AbYJBU5H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2008 16:57:07 -0400
Received: by wf-out-1314.google.com with SMTP id 27so1287259wfd.4
        for <netdev@vger.kernel.org>; Thu, 02 Oct 2008 13:57:05 -0700 (PDT)
In-Reply-To: <alpine.LFD.1.10.0810022113540.5549@apollo.tec.linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2 Oct 2008 21:16:32 +0200 (CEST)
Thomas Gleixner <tglx@linutronix.de> wrote:

> Hmm, not sure. sudo is a different beast. All I can see in the trace
> is that reiserfs is turning itself in circles (which is nothing new),
> but there is nothing which might tell us about a stall. At the point
> where you stopped the trace the relevant info was already replaced by
> new stuff. It's a circular buffer which gets overwritten.

	Ok, no problem.

	I'll keep waiting for a stall on the server-side..

-- 
