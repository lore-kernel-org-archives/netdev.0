From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: TCP default congestion control in linux should be newreno
Date: Thu, 4 Dec 2008 14:41:05 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0812041419500.26947@wrl-59.cs.helsinki.fi>
References: <b98e548c0812030637j2851ed76xb0768932b434e35c@mail.gmail.com>
 <b98e548c0812030812i3980791y2e4135cb9c5110c0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Saverio Mascolo <saverio.mascolo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:52566 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751567AbYLDMlJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2008 07:41:09 -0500
In-Reply-To: <b98e548c0812030812i3980791y2e4135cb9c5110c0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 3 Dec 2008, Saverio Mascolo wrote:

> we have added plots of cwnd at
> 
> http://c3lab.poliba.it/index.php/TCP_over_Hsdpa
> 
> in the case of newreno, wetwood+, bic/cubic.

You lack the most important detail, ie., the used kernel versions! And 
also information if some sysctls were tuned or not. This is especially 
important since you seem to claim that bic is the default which it hasn't 
been for years?!

> basically the goodput is similar with all variants  but with
> significantly larger packet losses and timeouts with bic/cubic.

I've never understood what exactly is wrong with the larger amount of 
packet losses if they happen before (or at the bottleneck), here they're 
just a consequence of having the larger window.

> i am pretty sure that this would happen with any algos -including h-tcp-
> that makes the probing more aggressive leaving the van jacobson linear
> phase.

Probably, but you seem to completely lack the analysis to find out why the 
rtos did actually happen, whether it was due to most of the window lost or 
perhaps spurious rtos?


-- 
 i.
