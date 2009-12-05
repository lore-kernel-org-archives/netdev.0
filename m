From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [PATCH net-next-2.6] drivers/net: Move && and || to end of previous
 line
Date: Sat, 05 Dec 2009 07:43:41 -0500
Message-ID: <4B1A557D.4080707@gmail.com>
References: <1259001504.16503.79.camel@Joe-Laptop.home>	 <20091123.104130.117837098.davem@davemloft.net>	 <1259528449.29779.194.camel@Joe-Laptop.home>	 <20091129.165557.84377714.davem@davemloft.net>	 <1259863101.22783.63.camel@Joe-Laptop.home>  <4B190A29.5080905@myri.com> <1259947271.22783.120.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Brice Goglin <brice@myri.com>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f187.google.com ([209.85.210.187]:61667 "EHLO
	mail-yx0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754527AbZLEMvO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Dec 2009 07:51:14 -0500
In-Reply-To: <1259947271.22783.120.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Perches wrote:
> On Fri, 2009-12-04 at 14:10 +0100, Brice Goglin wrote:
>> Joe Perches wrote:
>>> Only files where David Miller is the primary git-signer.
>>> wireless, wimax, ixgbe, etc are not modified.
>> What's the point? Having them at the beginning of the next line is
>> easier to read from my point of view.
> 
> It's just a stupid consistency thing.
> 
Brice, I've made my objection known on the LKML.  Joe *agrees* that
having them on the beginning of the line is preferred.  Thousands of
contributors throughout the tree agree.

This is entirely a Miller thing.

My main objection to these sweeping patches is that it makes it much
more difficult to maintain and apply patches across different versions of
the tree.  We have already seen conflicts with other git maintained trees.

These patches should not be accepted to the main Linus tree.
