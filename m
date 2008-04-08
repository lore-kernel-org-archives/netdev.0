From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Stochastic Fair Blue queue discipline
Date: Tue, 8 Apr 2008 19:53:53 +0200
Message-ID: <20080408175353.GA17147@one.firstfloor.org>
References: <87skxxb8br.fsf@pirx.pps.jussieu.fr> <873apwrc4t.fsf@basil.nowhere.org> <7i3apwbblk.fsf@lanthane.pps.jussieu.fr> <20080408163252.GS16647@one.firstfloor.org> <7iwsn8s107.fsf@lanthane.pps.jussieu.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org
To: Juliusz Chroboczek <Juliusz.Chroboczek@pps.jussieu.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:40906 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753764AbYDHRt3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2008 13:49:29 -0400
Content-Disposition: inline
In-Reply-To: <7iwsn8s107.fsf@lanthane.pps.jussieu.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 08, 2008 at 07:35:36PM +0200, Juliusz Chroboczek wrote:
> > no net_random/srandom32 is per CPU and likely does the wrong thing for you.
> 
> Why is that?  I'm only using this to initialise a global data
> structure, why should it matter that I use per-cpu state?

Because they're independent and there is no guarantee you always 
run on the same CPU and sampling them randomly will not necessarily
give you a good random number sequence.

-Andi
