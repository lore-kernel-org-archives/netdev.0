From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Why is gre0 auto-created, and can we fix it?
Date: Sun, 22 Jan 2012 11:43:25 -0800
Message-ID: <20120122114325.4a676e20@nehalam.linuxnetplumber.net>
References: <4F1AFA84.5050201@candelatech.com>
	<20120121.134036.1565691107664746948.davem@davemloft.net>
	<4F1C3DF5.8070802@candelatech.com>
	<20120122.141447.1622071157220040891.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, khc@pm.waw.pl, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49788 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752355Ab2AVTn2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Jan 2012 14:43:28 -0500
In-Reply-To: <20120122.141447.1622071157220040891.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 22 Jan 2012 14:14:47 -0500 (EST)
David Miller <davem@davemloft.net> wrote:

> From: Ben Greear <greearb@candelatech.com>
> Date: Sun, 22 Jan 2012 08:48:53 -0800
> 
> > Just to make sure I understand you: You dislike any possible method
> > of changing the behaviour, not just the ones I listed?
> 
> That's correct.
> 
> And please don't create dependencies on such a change in behavior in
> distributions, otherwise you obliterate the entire reason why I don't
> want the behavior changed.
> 
> There is no reason to change this, it's been like this for more than
> 10 years and no alien planet has exploded as a result even after all
> of this time.
> 
> Just leave it be, I beg you.

Also, the iproute tunnel tools rely on the module autoload
of gre0.
