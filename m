From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: Re: [PATCH net-next] tcp: add tcpi_segs_in and tcpi_segs_out to
 tcp_info
Date: Thu, 21 May 2015 09:38:45 -0300
Message-ID: <20150521123845.GQ2298@localhost.localdomain>
References: <1430260098-14127-1-git-send-email-edumazet@google.com>
 <20150512130855.GA29412@localhost.localdomain>
 <1431462713.566.95.camel@edumazet-glaptop2.roam.corp.google.com>
 <1432164941.4060.57.camel@edumazet-glaptop2.roam.corp.google.com>
 <555D218D.50509@hp.com>
 <1432168631.4060.69.camel@edumazet-glaptop2.roam.corp.google.com>
 <555D2B49.30702@hp.com>
 <1432169554.4060.71.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rick Jones <rick.jones2@hp.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Matt Mathis <mattmathis@google.com>,
	Craig Gallek <cgallek@google.com>, Martin Lau <kafai@fb.com>,
	Chris Rapier <rapier@psc.edu>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46779 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752832AbbEUMis (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 May 2015 08:38:48 -0400
Content-Disposition: inline
In-Reply-To: <1432169554.4060.71.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 20, 2015 at 05:52:34PM -0700, Eric Dumazet wrote:
> On Wed, 2015-05-20 at 17:48 -0700, Rick Jones wrote:
> > On 05/20/2015 05:37 PM, Eric Dumazet wrote:
> > 
> > > Anyway, if we can send tcp data at 100Gbits on one flow, I guess we are
> > > doing a terrific job and do not need to tweak TCP stack anymore ;)
> > 
> > :)
> > 
> 
> Note that I have no particular strong feelings with these counters being
> 32 or 64bits. Its adding 8 extra bytes and a bit more overhead, nothing
> more.

And if they really need an absolute number, 500s is still pretty much
enough for polling these and adding the delta to some local u64 var.

  Marcelo
  
