From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: IGMP joins come from the wrong SA/interface
Date: Fri, 31 Jan 2014 12:32:12 +0100
Message-ID: <20140131113212.GI25336@order.stressinduktion.org>
References: <20140118191107.GA21979@sesse.net> <20140119181806.GC16462@order.stressinduktion.org> <20140120184025.GA19972@sesse.net> <20140130104709.GA21178@sesse.net> <20140130180304.GA3793@plex.lan> <20140130181229.GA32245@sesse.net> <20140130224411.GG25336@order.stressinduktion.org> <alpine.LFD.2.11.1401310948270.1576@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "Steinar H. Gunderson" <sgunderson@bigfoot.com>,
	netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:49039 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932316AbaAaLcO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jan 2014 06:32:14 -0500
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1401310948270.1576@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 31, 2014 at 10:51:53AM +0200, Julian Anastasov wrote:
> 	To summarize: IGMP will use the same interface as
> selected from route to the joined multicast group but
> source can be from another device if for some reason there
> is no address on this interface.

Exactly that was my conclusion. As eth0.11 (as said in the second mail)
is a leg of a bridge I concluded that there is no ip address on that
interface.

Greetings,

  Hannes
