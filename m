From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT]: Networking
Date: Mon, 21 Jul 2008 10:40:24 -0700 (PDT)
Message-ID: <alpine.LFD.1.10.0807211037200.31863@woody.linux-foundation.org>
References: <4883E465.4050405@trash.net> <Xine.LNX.4.64.0807212143540.17349@us.intercode.com.au> <48847BA5.2020600@trash.net> <20080721.102852.124418551.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: kaber@trash.net, jmorris@namei.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:60632 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751426AbYGURkb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 13:40:31 -0400
In-Reply-To: <20080721.102852.124418551.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Mon, 21 Jul 2008, David Miller wrote:

> From: Patrick McHardy <kaber@trash.net>
> Date: Mon, 21 Jul 2008 14:05:57 +0200
> 
> > The idea was that NETFILTER_ADVANCED=n enables everything needed
> > by mainstream distributions and hides the rest. We can certainly
> > change the default for this option, but that makes NETFILTER_ADVANCED
> > pretty much useless.
> 
> A new feature cannot possibly be used by existing distributions.  I
> think that's the main gripe.

Well, if the feature really is going to be something that a _normal_ 
netfilter config needs, then it should indeed be turned on.

However, nothing in the docs imply that at all. Can you explain? Why 
should IP_NF_SECURITY be on, and why should a default netfilter table 
enable it? And if it should, WHY THE HELL IS IT DOCUMENTED THAT YOU SHOULD 
SAY 'N'?

Patrick, see my original report:

> Grr. And I quote:
> 
>         Security table (IP_NF_SECURITY) [Y/n/?] (NEW) ?
>       
>       This option adds a `security' table to iptables, for use
>       with Mandatory Access Control (MAC) policy.
>       
>       If unsure, say N.


That option as it stands now MAKES NO SENSE. Either you should say 'Y' 
(and you should explain _why_), or you should say 'N' (as documented) and 
it should damn well default to 'N' too!

		Linus
