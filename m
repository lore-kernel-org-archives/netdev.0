From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 NEXT 1/2] net: add external loopback test in ethtool
 self test
Date: Thu, 30 Jun 2011 23:58:47 -0700 (PDT)
Message-ID: <20110630.235847.1364630282954525785.davem@davemloft.net>
References: <1309413650-15952-1-git-send-email-amit.salecha@qlogic.com>
	<1309413650-15952-2-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org,
	ameen.rahman@qlogic.com, sucheta.chakraborty@qlogic.com
To: amit.salecha@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36293 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755011Ab1GAG64 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2011 02:58:56 -0400
In-Reply-To: <1309413650-15952-2-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: amit.salecha@qlogic.com
Date: Wed, 29 Jun 2011 23:00:49 -0700

> From: Amit Kumar Salecha <amit.salecha@qlogic.com>
> 
> External loopback test can be performed by application without any driver
> support on normal Ethernet cards.
> But on CNA devices, where multiple functions share same physical port.
> Here internal loopback test and external loopback test can be initiated by
> multiple functions at same time. To co exist all functions, firmware need
> to regulate what test can be run by which function. So before performing external
> loopback test, command need to send to firmware, which will quiescent other functions.
> 
> User may not want to run external loopback test always. As special cable need to be
> connected for this test.
> So adding explicit flag in ethtool self test, which will specify interface
> to perform external loopback test.
>  ETH_TEST_FL_EXTERNAL_LB: Application set to request external loopback test
>  ETH_TEST_FL_EXTERNAL_LB_DONE: Driver ack if test performed
> 
> Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>

Applied.
