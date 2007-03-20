From: Patrick McHardy <kaber@trash.net>
Subject: Re: Oops in filter add
Date: Tue, 20 Mar 2007 08:29:46 +0100
Message-ID: <45FF8D6A.4010308@trash.net>
References: <45FEEE35.6090606@reflexsecurity.com>	 <20070319.192206.21926062.davem@davemloft.net>	 <1174373645.4895.15.camel@localhost>  <45FF8602.8040108@trash.net> <1174375109.4895.22.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, chris@reflexsecurity.com,
	netdev@vger.kernel.org, tgraf@suug.ch
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42521 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753341AbXCTH3u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 03:29:50 -0400
In-Reply-To: <1174375109.4895.22.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Tue, 2007-20-03 at 07:58 +0100, Patrick McHardy wrote:
> 
> Ok. It certainly used to matter in the old days.


Actually it has never been used anywhere else but in ing_filter,
it was introduced together with the TC actions.

>>You would need to make qdisc_lock_tree() aware of the difference
>>between ingress and egress.
> 
> 
> If you have the cycles please go ahead - I really dont have much time
> today (have to present in a few hours and havent even started).
> I will most certainly look in 1-2 days; for now the queue_lock should
> suffice; 


I'll try, but no promises, I'm a bit behind with various things myself.
