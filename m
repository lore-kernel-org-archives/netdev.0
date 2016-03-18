From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH] sctp: align MTU to a word
Date: Fri, 18 Mar 2016 19:33:46 -0300
Message-ID: <20160318223346.GC3387@mrl.redhat.com>
References: <1458337159-22792-1-git-send-email-marcelo.leitner@gmail.com>
 <1458338974.31963.15.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>, linux-sctp@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55458 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751350AbcCRWdt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Mar 2016 18:33:49 -0400
Content-Disposition: inline
In-Reply-To: <1458338974.31963.15.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 18, 2016 at 03:09:34PM -0700, Eric Dumazet wrote:
> On Fri, 2016-03-18 at 18:39 -0300, Marcelo Ricardo Leitner wrote:
> 
> > -		transport->pathmtu = dst_mtu(transport->dst);
> > +		transport->pathmtu = dst_mtu(transport->dst) & ~3;
> 
> 
> Well, surely a helper doing this would be better than spreading & ~3 all
> over the places ;)

Heh.. agreed
for this and the other patch too, will post a v2
Thanks
