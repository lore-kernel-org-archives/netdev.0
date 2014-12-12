From: Tobias Klauser <tklauser@distanz.ch>
Subject: Re: [PATCH net] net: ethernet: davicom: Allow to select DM9000 for
 nios2
Date: Fri, 12 Dec 2014 10:57:17 +0100
Message-ID: <20141212095717.GF16916@distanz.ch>
References: <1418376071-28709-1-git-send-email-tklauser@distanz.ch>
 <063D6719AE5E284EB5DD2968C1650D6D1CA0BA4C@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sym2.noone.org ([178.63.92.236]:60189 "EHLO sym2.noone.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934700AbaLLJ5U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Dec 2014 04:57:20 -0500
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CA0BA4C@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014-12-12 at 10:49:13 +0100, David Laight <David.Laight@ACULAB.COM> wrote:
> From: Tobias Klauser
> > This chip is present on older revisions of the DE2 development kit.
> 
> Doesn't that mean the selector should be DE2 not NIOS2.
> 
> NIOS2 is a cpu not a board and I think this is an external peripheral
> not something implemented in the fpga itself.

You're of course right, but since nios2 relies on device tree there is
no notion of a specific board at compile time.

Moreover, the chip might be used on other boards (I personally know of
at least one) based on the nios2 softcore.

Cheers
Tobias
