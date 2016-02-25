From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: RFC: blueprint for proxy PHY module
Date: Thu, 25 Feb 2016 16:31:13 +0100
Message-ID: <20160225153113.GB7681@lunn.ch>
References: <1456406760.28260.6@smtp.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Pavol Kor?ek <ikorcek@fit.vutbr.cz>,
	Martin Strba?ka <martin.strbacka@nic.cz>
To: Tomas Hlavacek <tmshlvck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:42795 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760613AbcBYPbP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Feb 2016 10:31:15 -0500
Content-Disposition: inline
In-Reply-To: <1456406760.28260.6@smtp.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Question is how to connect the userspace? I think that corresponding
> file in /sys would do the job, but I am not sure whether it is the
> proper way of doing that. (?)

A historian might be able to help you. Going back to the days of
10MBps Ethernet, cards used to have a few different ports, AUI, BNC
and TP. The kernel probably supports configuring which to use,
probably via ethtool. Your use case is not that different, so you can
probably reuse it.

	 Andrew
