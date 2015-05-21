From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: add tcpi_segs_in and tcpi_segs_out to
 tcp_info
Date: Wed, 20 May 2015 17:52:34 -0700
Message-ID: <1432169554.4060.71.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1430260098-14127-1-git-send-email-edumazet@google.com>
	 <20150512130855.GA29412@localhost.localdomain>
	 <1431462713.566.95.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1432164941.4060.57.camel@edumazet-glaptop2.roam.corp.google.com>
	 <555D218D.50509@hp.com>
	 <1432168631.4060.69.camel@edumazet-glaptop2.roam.corp.google.com>
	 <555D2B49.30702@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Marcelo Ricardo Leitner <mleitner@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Matt Mathis <mattmathis@google.com>,
	Craig Gallek <cgallek@google.com>, Martin Lau <kafai@fb.com>,
	Chris Rapier <rapier@psc.edu>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:37071 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753150AbbEUAwg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 20:52:36 -0400
Received: by igbsb11 with SMTP id sb11so53476552igb.0
        for <netdev@vger.kernel.org>; Wed, 20 May 2015 17:52:35 -0700 (PDT)
In-Reply-To: <555D2B49.30702@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-05-20 at 17:48 -0700, Rick Jones wrote:
> On 05/20/2015 05:37 PM, Eric Dumazet wrote:
> 
> > Anyway, if we can send tcp data at 100Gbits on one flow, I guess we are
> > doing a terrific job and do not need to tweak TCP stack anymore ;)
> 
> :)
> 

Note that I have no particular strong feelings with these counters being
32 or 64bits. Its adding 8 extra bytes and a bit more overhead, nothing
more.
