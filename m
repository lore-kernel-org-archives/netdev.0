From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net PATCH] atl1c: Fix misuse of netdev_alloc_skb in refilling
 rx ring
Date: Mon, 29 Jul 2013 08:30:04 -0700
Message-ID: <1375111804.10515.1.camel@edumazet-glaptop>
References: <87k3kbdcmy.fsf@canonical.com>
	 <1374960610.3607.13.camel@deadeye.wl.decadent.org.uk>
	 <1374969583.3669.23.camel@edumazet-glaptop>
	 <20130727.200205.67471633133830510.davem@davemloft.net>
	 <20130728104446.GB9876@neilslaptop.think-freely.org>
	 <1375028154.3669.30.camel@edumazet-glaptop>
	 <20130728185318.GA10795@neilslaptop.think-freely.org>
	 <1375042972.2546.17.camel@deadeye.wl.decadent.org.uk>
	 <1375052482.3669.54.camel@edumazet-glaptop>
	 <1375053654.3669.58.camel@edumazet-glaptop> <877gg9wv08.fsf@canonical.com>
	 <1375095442.3669.67.camel@edumazet-glaptop> <87y58pva88.fsf@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jcliburn@gmail.com, stable@vger.kernel.org
To: Luis Henriques <luis.henriques@canonical.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <87y58pva88.fsf@canonical.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-07-29 at 13:09 +0100, Luis Henriques wrote:

> 
> I confirm that I can't reproduce the issue using this patch.
> 

Thanks, I'll send a polished patch, as this one had an error if
build_skb() returns NULL (in case sk_buff allocation fails)
