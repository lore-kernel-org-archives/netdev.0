From: David Miller <davem@davemloft.net>
Subject: Re: increase the number of routing tables
Date: Sun, 29 Jan 2012 16:02:50 -0500 (EST)
Message-ID: <20120129.160250.471951331979463712.davem@davemloft.net>
References: <1327804887.2805.20.camel@edumazet-laptop>
	<4F24B2E9.3010600@candelatech.com>
	<CANj2EbdFc33ciZ02ZCF7=3sY1XTbCLrdfu4Mp_vLp4N94xu5Cw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: simonchennj@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59769 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752674Ab2A2VCx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jan 2012 16:02:53 -0500
In-Reply-To: <CANj2EbdFc33ciZ02ZCF7=3sY1XTbCLrdfu4Mp_vLp4N94xu5Cw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Chen <simonchennj@gmail.com>
Date: Sat, 28 Jan 2012 23:20:33 -0500

> I wonder if we can use a trie-tree for "ip rule" - linear evaluation
> does not sound too good. But I'll be using a ton of iptables rules as
> well, and I believe those are linear evaluation too :-(

You cannot use a trie because the rules are defined to be evaluated
in the order they were added to the kernel, it is the same problem
that basic firewall rule tables have.
