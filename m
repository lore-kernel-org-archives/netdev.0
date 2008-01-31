From: Andi Kleen <ak@suse.de>
Subject: Re: hard hang through qdisc
Date: Thu, 31 Jan 2008 14:28:48 +0100
Message-ID: <200801311428.48175.ak@suse.de>
References: <200801311321.01015.ak@suse.de> <1201782841.4732.11.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:60858 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758631AbYAaN2w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jan 2008 08:28:52 -0500
In-Reply-To: <1201782841.4732.11.camel@localhost>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> ---------
> lilsol:~# tc qdisc add dev eth0 root tbf rate 1000 burst 10 limit 100
> lilsol:~# uname -a
> Linux lilsol 2.6.24 #1 PREEMPT Sun Jan 27 09:22:00 EST 2008 i686

Can you try it again with current git mainline?

> GNU/Linux
> lilsol:~# tc qdisc ls dev eth0
> qdisc tbf 8001: root rate 1000bit burst 10b lat 737.3ms
> lilsol:~#
> -------
> 
> What do your patches do?

Nothing really related to qdiscs.  I suspect it came from the git mainline patch
I had (but forgot to mention in the first email) 

-Andi

