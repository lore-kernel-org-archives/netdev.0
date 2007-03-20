From: Patrick McHardy <kaber@trash.net>
Subject: Re: Oops in filter add
Date: Tue, 20 Mar 2007 16:13:58 +0100
Message-ID: <45FFFA36.7080404@trash.net>
References: <45FEEE35.6090606@reflexsecurity.com> <20070319.192206.21926062.davem@davemloft.net> <1174373645.4895.15.camel@localhost> <45FFEC78.2090708@reflexsecurity.com> <45FFF455.80003@trash.net> <45FFF675.8040501@trash.net> <20070320151151.GM521@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Chris Madden <chris@reflexsecurity.com>, hadi@cyberus.ca,
	netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52115 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933633AbXCTPOG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 11:14:06 -0400
In-Reply-To: <20070320151151.GM521@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> * Patrick McHardy <kaber@trash.net> 2007-03-20 15:57
> 
>>Actually its only cls_basic thats broken, in case of route and fw
>>its intentional for backwards-compatibility.
> 
> 
> Absolutely right, thanks Patrick.


There was a small bug in my patch (broken return value on memory
allocation failure, not relevant for testing though). I'll push
the fixed patch to Dave once Chris confirms that it fixes the
problem he's seeing.

