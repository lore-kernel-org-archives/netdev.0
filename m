From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [RFC][PATCH 8/9] 3c59x driver conversion
Date: Sun, 13 Aug 2006 15:53:50 -0400
Message-ID: <44DF834E.4020302@garzik.org>
References: <20060808193447.1396.59301.sendpatchset@lappy>	<44D9191E.7080203@garzik.org>	<44D977D8.5070306@google.com> <20060808.225537.112622421.davem@davemloft.net> <44DF7FB9.8020003@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, a.p.zijlstra@chello.nl,
	netdev@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:29160 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1751395AbWHMTx5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Aug 2006 15:53:57 -0400
To: Daniel Phillips <phillips@google.com>
In-Reply-To: <44DF7FB9.8020003@google.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Daniel Phillips wrote:
> That is why it has not yet been submitted upstream.  Respectfully, I
> do not think that jgarzik has yet put in the work to know if this anti
> deadlock technique is reasonable or not, and he was only commenting
> on some superficial blemish.  I still don't get his point, if there
> was one.  He seems to be arguing in favor of a jump-off-the-cliff
> approach to driver conversion.  If he wants to do the work and take
> the blame when some driver inevitably breaks because of being edited
> in a hurry then he is welcome to submit the necessary additional
> patches.  Until then, there are about 3 nics that actually matter to
> network storage at the moment, all of them GigE.

Quite whining and blaming the reviewer for a poor approach.

A "this driver is sane, VM-wise" flag is just plain stupid, and clearly 
fragments drivers.

In Linux, "temporary flags"... aren't.

	Jeff



