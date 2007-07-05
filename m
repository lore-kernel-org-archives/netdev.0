From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: Who's allowed to set a skb destructor?
Date: Thu, 5 Jul 2007 15:00:12 +0200
Message-ID: <20070705130012.GB4759@ff.dom.local>
References: <p733b032mec.fsf@bingen.suse.de> <20070705122849.GA4759@ff.dom.local> <20070705122847.GA13368@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	Brice Goglin <Brice.Goglin@ens-lyon.org>,
	netdev@vger.kernel.org, Divy Le Ray <divy@chelsio.com>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx12.go2.pl ([193.17.41.142]:37217 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755092AbXGEMvo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jul 2007 08:51:44 -0400
Content-Disposition: inline
In-Reply-To: <20070705122847.GA13368@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 05, 2007 at 04:28:47PM +0400, Evgeniy Polyakov wrote:
> Hi, Jarek.
> 
> On Thu, Jul 05, 2007 at 02:28:50PM +0200, Jarek Poplawski (jarkao2@o2.pl) wrote:
> > I wonder if it's very unsound to think about a one way list
> > of destructors. Of course, not owners could only clean their
> > private allocations. Woudn't this save some skb clonning,
> > copying or adding new fields for private infos?
> 
> There should not be any additional allocations, since they are very
> slow, that part of mbuf is really horrible for performance - openbsd
> hackers removed additional allocation of mbuf tag in PF code during the
> last hackathon, which doubled its performance, that is why skb has only 
> one control structure and data area, which incorporates additional 
> control information, thus there is no need for multiple destructors.

Of course, my knowledge of this is far not enough, and maybe
I got this reversed, but from Andi's words I've understood
that linux prefers another (mixed) approach, so I've thought
such list should be a consequence...

Thanks,
Jarek P.
