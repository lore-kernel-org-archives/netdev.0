From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: mvneta: fix refilling for Rx DMA buffers
Date: Wed, 15 Jul 2015 17:29:15 -0700 (PDT)
Message-ID: <20150715.172915.79534987578944851.davem@davemloft.net>
References: <1436738697-21652-1-git-send-email-simon.guinot@sequanux.org>
	<20150715.155256.1854323748613951804.davem@davemloft.net>
	<20150716002530.GD10671@kw.sim.vm.gnt>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com, jason@lakedaemon.net,
	andrew@lunn.ch, gregory.clement@free-electrons.com,
	sebastian.hesselbarth@gmail.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, vdonnefort@gmail.com,
	yoann@sculo.fr, stable@vger.kernel.org
To: simon.guinot@sequanux.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20150716002530.GD10671@kw.sim.vm.gnt>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Simon Guinot <simon.guinot@sequanux.org>
Date: Thu, 16 Jul 2015 02:25:30 +0200

> On Wed, Jul 15, 2015 at 03:52:56PM -0700, David Miller wrote:
>> Failed memory allocations, are normal and if necessary kernel log
>> messages will be triggered by the core memory allocator.  So there is
>> zero reason to do anything other than bump the drop counter in your
>> driver.
> 
> Sure.

Ok so just get rid of this log message in your patch and resubmit,
thanks.
