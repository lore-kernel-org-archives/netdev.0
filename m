From: David Miller <davem@davemloft.net>
Subject: Re: A Linux TCP SACK Question
Date: Wed, 16 Apr 2008 01:27:32 -0700 (PDT)
Message-ID: <20080416.012732.152357000.davem@davemloft.net>
References: <Pine.LNX.4.64.0804151035060.17123@wrl-59.cs.helsinki.fi>
	<fc3c25e72104.4804a729@fnal.gov>
	<1e41a3230804151540i1f7cee4dva6adc6ef25dae546@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wenji@fnal.gov, ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: johnwheffner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36900
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753834AbYDPI1b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2008 04:27:31 -0400
In-Reply-To: <1e41a3230804151540i1f7cee4dva6adc6ef25dae546@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "John Heffner" <johnwheffner@gmail.com>
Date: Tue, 15 Apr 2008 15:40:05 -0700

> Subject: [PATCH] Increase the max_burst threshold from 3 to tp->reordering.
> 
> This change is necessary to allow cwnd to grow during persistent
> reordering.  Cwnd moderation is applied when in the disorder state
> and an ack that fills the hole comes in.  If the hole was greater
> than 3 packets, but less than tp->reordering, cwnd will shrink when
> it should not have.
> 
> Signed-off-by: John Heffner <jheffner@napa.(none)>

I think this patch is correct, or at least more correct than what
this code is doing right now.

Any objections to my adding this to net-2.6.26?
