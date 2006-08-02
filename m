From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] SMSC LAN911x and LAN921x vendor driver
Date: Wed, 2 Aug 2006 15:51:33 -0400
Message-ID: <20060802195128.GA7204@tuxdriver.com>
References: <20060801153313.GD29208@tuxdriver.com> <OF9CB563CF.865D1AC6-ON802571BE.006924E4-802571BE.006A884B@smsc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bahadir Balban <Bahadir.Balban@arm.com>, ian.saturley@smsc.com,
	netdev@vger.kernel.org, Francois Romieu <romieu@fr.zoreil.com>,
	Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:6919 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S932195AbWHBTv6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2006 15:51:58 -0400
To: Steve.Glendinning@smsc.com
Content-Disposition: inline
In-Reply-To: <OF9CB563CF.865D1AC6-ON802571BE.006924E4-802571BE.006A884B@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 02, 2006 at 08:23:40PM +0100, Steve.Glendinning@smsc.com wrote:

> > Does this need the magic "for (addr=1; addr <=32; addr++)" trick that
> > has become idiomatic for PHY discovery in our drivers?
> 
> I don't understand the question - surely 32 is not a valid PHY address?

That's why it is magic! :-)

The idea is to probe PHY addr 0 last in the series.  Apparently some
PHYs don't like seeing addr 0 or somesuch, so you try it last to avoid
screwing them up.  It may well be folklore and legend at this point.
Still, you will find several examples in the various drivers.
The sundance driver is one example.

John
-- 
John W. Linville
linville@tuxdriver.com
