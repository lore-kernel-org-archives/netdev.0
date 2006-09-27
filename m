From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] skge: fiber support
Date: Wed, 27 Sep 2006 10:34:15 -0700
Message-ID: <20060927103415.21bdccc9@freekitty>
References: <20060815131852.GP2900@mathom.us>
	<20060921153939.739947ab@dxpl.pdx.osdl.net>
	<20060926154459.GA6030@mathom.us>
	<20060927172644.GA14294@mathom.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:11432 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1030475AbWI0Re1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2006 13:34:27 -0400
To: Michael Stone <mstone@mathom.us>
In-Reply-To: <20060927172644.GA14294@mathom.us>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 27 Sep 2006 13:26:46 -0400
Michael Stone <mstone@mathom.us> wrote:

> Hmm. Yesterday I did some nfs testing (simple dd of a big file) with the 
> skge driver and got about 700+Mbps. I ran the same test today and got 
> 160Mbps. I rebooted the client and got 700+Mbps again. About half an 
> hour later, down to 160Mbps again. Server & client were both idle, and 
> the server didn't change (no reboots). For reference, the sk98lin gets 
> around 600Mbps, consistently.
> 
> Mike Stone

That's surprising, memory leak? dropped packets?

-- 
Stephen Hemminger <shemminger@osdl.org>
