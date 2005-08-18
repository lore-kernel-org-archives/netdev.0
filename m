From: "David S. Miller" <davem@davemloft.net>
Subject: Re: overflows in /proc/net/dev
Date: Thu, 18 Aug 2005 14:32:48 -0700 (PDT)
Message-ID: <20050818.143248.58283961.davem@davemloft.net>
References: <1124350090.29902.8.camel@basti79.freenet-ag.de>
	<20050818163358.GA19554@taniwha.stupidest.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Sebastian.Classen@freenet-ag.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932465AbVHRVdo@vger.kernel.org>
To: cw@f00f.org
In-Reply-To: <20050818163358.GA19554@taniwha.stupidest.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Wedgwood <cw@f00f.org>
Date: Thu, 18 Aug 2005 09:33:58 -0700

> I thought the concensurs here was that because doing reliable atomic
> updates of 64-bit values isn't possible on some (most?) 32-bit
> architectures so we need additional locking to make this work which is
> undesirable?  (It might even be a FAQ by now as this comes up fairly
> often).

That's correct.
