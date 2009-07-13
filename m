From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gre: copy ToS/DiffServ bits to outer IP header
Date: Mon, 13 Jul 2009 09:27:25 -0700 (PDT)
Message-ID: <20090713.092725.90035484.davem@davemloft.net>
References: <20090713083303.61a59b63@nehalam>
	<20090713160142.GA9252@urbino.open.ch>
	<20090713090743.27e1b8ea@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: aj@open.ch, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	kaber@trash.net
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46140
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756533AbZGMQ1V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2009 12:27:21 -0400
In-Reply-To: <20090713090743.27e1b8ea@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 13 Jul 2009 09:07:43 -0700

> On Mon, 13 Jul 2009 18:01:42 +0200
> Andreas Jaggi <aj@open.ch> wrote:
> 
>> On Mon, Jul 13, 2009 at 08:33:03AM -0700, Stephen Hemminger wrote:
>> > Why make it an option? Sounds like it should always be on.
>> 
>> In some scenarios people might want to set the ToS value for all
>> GRE tunnel packets to a fixed value (cf. ip tunnel tos option).
> 
> Having more options, does not help users.  Why not just do that
> with iptables or classifiers?

I think we should behave however our other IP tunnels behave by
default in this situation.

But regardless, always there is the argument that changing default
behavior is surprising and will bite someone.
