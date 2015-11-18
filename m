From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH -next] net: tcp: move to timewait when receiving data
 post active-close
Date: Wed, 18 Nov 2015 18:32:34 +0100
Message-ID: <20151118173234.GB5860@breakpoint.cc>
References: <1447859024-1040-1-git-send-email-fw@strlen.de>
 <1447860480.22599.151.camel@edumazet-glaptop2.roam.corp.google.com>
 <20151118153621.GA5860@breakpoint.cc>
 <1447861591.22599.157.camel@edumazet-glaptop2.roam.corp.google.com>
 <1447862057.909111.443349025.5B7D067D@webmail.messagingengine.com>
 <1447867736.22599.169.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	marcelo.leitner@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:46289 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755238AbbKRRcg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2015 12:32:36 -0500
Content-Disposition: inline
In-Reply-To: <1447867736.22599.169.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2015-11-18 at 16:54 +0100, Hannes Frederic Sowa wrote:
> 
> > Still, the RST packet can be dropped along the way. So the teardown of
> > the socket on the other side might not happen.
> 
> This is why it is better to send RST for every incoming in-excess packet

I'm convinced and marked patch as rejected in patchwork.

Thanks Eric!
